//
//  SessionDelegate+Swizzle.swift
//  
//
//  Created by Branden Smith on 3/30/21.
//

import Alamofire
import Foundation

extension SessionDelegate {
    static func swizzleURLSessionTaskDidReceiveData() {
        method_exchangeImplementations(
            class_getInstanceMethod(
                SessionDelegate.self,
                #selector(SessionDelegate.urlSession(_:dataTask:didReceive:))
            )!,
            class_getInstanceMethod(
                SessionDelegate.self,
                #selector(SessionDelegate.swizzledURLSessionTaskDidReceiveData(_:dataTask:didReceive:))
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
}
