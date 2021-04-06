//
//  URLSession+Swizzle.swift
//  
//
//  Created by Branden Smith on 3/29/21.
//

import Alamofire
import Foundation

extension URLSession {
    private typealias CombinedDataTask = @convention(c) (AnyObject, Selector, URLRequest, (Data?, URLResponse?, Error?) -> Void) -> Void
    private static let oldSelector = #selector(URLSession.dataTask(with:completionHandler:) as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask)

    static func swizzleDataTaskWithRequestCompletion() {
        method_exchangeImplementations(
            class_getInstanceMethod(URLSession.self, oldSelector)!,
            class_getInstanceMethod(URLSession.self, #selector(swizzledDataTask(with:completionHandler:)))!
        )
    }

    @objc func swizzledDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let networkRequest = NetworkRequest(date: Date(), request: request)
        networkTrafficManager.addRequest(networkRequest)

        let replacedCompletion: (Data?, URLResponse?, Error?) -> Void = { (data, response, error) in
            networkTrafficManager.pairResponse(
                response: NetworkResponse(date: Date(), response: response, data: data, error: error),
                with: networkRequest
            )

            completionHandler(data, response, error)
        }

        return swizzledDataTask(with: request, completionHandler: replacedCompletion)
    }

    static func swizzleDataTaskWithRequest() {
        method_exchangeImplementations(
            class_getInstanceMethod(
                URLSession.self,
                #selector(URLSession.dataTask(with:) as (URLSession) -> (URLRequest) -> URLSessionDataTask)
            )!,
            class_getInstanceMethod(URLSession.self, #selector(swizzledDataTask(with:)))!
        )
    }

    @objc func swizzledDataTask(with request: URLRequest) -> URLSessionDataTask {
        if let queryParams = MockDataHelper.parseParams(from: request.url?.query),
           let useMockData = Bool(queryParams["mockData"] as! String),
           useMockData {
            let shouldMock = try? networkTrafficManager
                .mockDataManager?
                .shouldMockResponse(for: request.url!.absoluteString.components(separatedBy: "?")[0])
            if shouldMock ?? false {
                let fakeTask = FakeURLSessionTask(
                    request: request,
                    session: self
                )

                return fakeTask
            }
        }

        return swizzledDataTask(with: request)
    }
}

final class FakeURLSessionTask: URLSessionDataTask {
    override func resume() {
        let start = Date()
        let mockResponse = try! networkTrafficManager.mockDataManager!.mockResponse(
            for: _originalRequest.url!.absoluteString.components(separatedBy: "?")[0]
        )

        let bytesToSend = Int64(_originalRequest.httpBody?.count ?? 0)
        (self.session?.delegate as? URLSessionTaskDelegate)?.urlSession?(
            self.session!,
            task: self,
            didSendBodyData: bytesToSend,
            totalBytesSent: bytesToSend,
            totalBytesExpectedToSend: bytesToSend
        )

        self._response = HTTPURLResponse(
            url: URL(string: mockResponse.url)!,
            statusCode: mockResponse.statusCode,
            httpVersion: mockResponse.httpVersion,
            headerFields: mockResponse.headerFields
        )!

        (self.session?.delegate as? URLSessionDataDelegate)?.urlSession?(
            self.session!,
            dataTask: self,
            didReceive: self.response!,
            completionHandler: { (responseDisposition) in }
        )

        if let data = mockResponse.body {
            (self.session?.delegate as? URLSessionDataDelegate)?.urlSession?(self.session!, dataTask: self, didReceive: data)
            (self.session?.delegate as? URLSessionDataDelegate)?.urlSession?(
                self.session!,
                dataTask: self,
                willCacheResponse: CachedURLResponse(response: self.response!, data: data),
                completionHandler: { cachedResponse in }
            )
        }

        (self.session?.delegate as? URLSessionTaskDelegate)?.urlSession?(self.session!, task: self, didCompleteWithError: nil)

        (self.session?.delegate as? URLSessionTaskDelegate)?.urlSession?(
            self.session!,
            task: self,
            didFinishCollecting: FakeURLSessionTaskMetrics(
                taskInterval: DateInterval(start: start, duration: Date().timeIntervalSince(start)),
                redirectCount: 0
            )
        )
    }

    private weak var session: URLSession?
    private let _originalRequest: URLRequest
    private var _response: HTTPURLResponse?

    override var originalRequest: URLRequest? {
        return _originalRequest
    }

    override var state: URLSessionTask.State {
        return super.state
    }

    override var response: URLResponse? {
        return _response
    }

    init(request: URLRequest, session: URLSession) {
        self.session = session
        self._originalRequest = request
    }
}

final class FakeURLSessionTaskMetrics: URLSessionTaskMetrics {
    private let _fakeInterval: DateInterval
    private let _fakeRedirectCount: Int

    override var taskInterval: DateInterval {
        return _fakeInterval
    }

    override var redirectCount: Int {
        return _fakeRedirectCount
    }

    init(taskInterval: DateInterval, redirectCount: Int) {
        self._fakeInterval = taskInterval
        self._fakeRedirectCount = redirectCount
    }
}
