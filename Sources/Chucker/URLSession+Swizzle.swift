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

    static func swizzleDataTaskWithRequest() {
        method_exchangeImplementations(
            class_getInstanceMethod(
                URLSession.self,
                #selector(URLSession.dataTask(with:) as (URLSession) -> (URLRequest) -> URLSessionDataTask)
            )!,
            class_getInstanceMethod(URLSession.self, #selector(swizzledDataTask(with:)))!
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

    @objc func swizzledDataTask(with request: URLRequest) -> URLSessionDataTask {
        return dataTask(with: request, completionHandler: { (data, response, error) in
            // Do nothing, we expect our swizzled version of this method to insert the correct completion here.
        })
    }
}
