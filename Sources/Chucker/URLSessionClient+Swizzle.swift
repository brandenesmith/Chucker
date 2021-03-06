//
//  URLSessionClient+Swizzle.swift
//  
//
//  Created by Branden Smith on 3/30/21.
//

import Apollo
import Foundation

extension URLSessionClient {
    static func swizzleURLSessionTaskDidReceiveData() {
        method_exchangeImplementations(
            class_getInstanceMethod(
                URLSessionClient.self,
                #selector(URLSessionClient.urlSession(_:dataTask:didReceive:))
            )!,
            class_getInstanceMethod(
                URLSessionClient.self,
                #selector(URLSessionClient.swizzledURLSessionTaskDidReceiveData(_:dataTask:didReceive:))
            )!
        )
    }

    static func swizzleURLSessionTaskDidCompleteWithError() {
        method_exchangeImplementations(
            class_getInstanceMethod(
                URLSessionClient.self,
                #selector(URLSessionClient.urlSession(_:task:didCompleteWithError:))
            )!,
            class_getInstanceMethod(
                URLSessionClient.self,
                #selector(URLSessionClient.swizzledUrlSessionTaskDidCompleteWithError(_:task:didCompleteWithError:))
            )!
        )
    }

    @objc func swizzledURLSessionTaskDidReceiveData(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let networkRequest = NetworkRequest(date: Date(), request: dataTask.originalRequest!)
        networkTrafficManager.addRequest(networkRequest)

        networkTrafficManager.pairResponse(
            response: NetworkResponse(date: Date(), response: dataTask.response, data: data, error: dataTask.error),
            with: networkRequest
        )

        return swizzledURLSessionTaskDidReceiveData(session, dataTask: dataTask, didReceive: data)
    }

    @objc func swizzledUrlSessionTaskDidCompleteWithError(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer { swizzledUrlSessionTaskDidCompleteWithError(session, task: task, didCompleteWithError: error) }

        guard let error = error else { return }

        let networkRequest = NetworkRequest(date: Date(), request: task.originalRequest!)
        networkTrafficManager.addRequest(networkRequest)

        networkTrafficManager.pairResponse(
            response: NetworkResponse(date: Date(), response: task.response, data: nil, error: error),
            with: networkRequest
        )
    }
}
