//
//  URLSession+Swizzle.swift
//  
//
//  Created by Branden Smith on 3/29/21.
//

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
           queryParams.contains(where: { (key, _) in key == "mockData" }) {
            let fakeTask = FakeURLSessionTask(
                request: request,
                session: self,
                mockPath: queryParams["mockData"] as! String
            )

            return fakeTask
        }

        return swizzledDataTask(with: request)
    }
}

final class FakeURLSessionTask: URLSessionDataTask {
    override func resume() {
        let data = """
                    [
                                {
                                    "question": "Test Question Fool",
                                    "published_at": "2015-08-05T08:40:51.620Z",
                                    "choices": [
                                        {
                                            "choice": "Test 1",
                                            "votes": 2048
                                        }, {
                                            "choice": "Test 2",
                                            "votes": 1024
                                        }, {
                                            "choice": "Test 3",
                                            "votes": 512
                                        }, {
                                            "choice": "Test 4",
                                            "votes": 256
                                        }
                                    ]
                                }
                            ]
        """.data(using: .utf8)

        (self.session?.delegate as? URLSessionDataDelegate)?.urlSession?(
            self.session!,
            dataTask: self,
            didReceive: URLResponse(
                url: _originalRequest.url!,
                mimeType: nil,
                expectedContentLength: 2048,
                textEncodingName: "utf-8"
            ),
            completionHandler: { (responseDisposition) in }
        )

        (self.session?.delegate as? URLSessionDataDelegate)?.urlSession?(self.session!, dataTask: self, didReceive: data!)
    }

    private weak var session: URLSession?
    private let mockPath: String
    private let _originalRequest: URLRequest

    override var originalRequest: URLRequest? {
        return _originalRequest
    }

    override var state: URLSessionTask.State {
        return super.state
    }

    init(request: URLRequest, session: URLSession, mockPath: String) {
        self.session = session
        self.mockPath = mockPath
        self._originalRequest = request
    }
}
