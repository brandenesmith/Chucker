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

    static func swizzleURLSessionTaskDidCompleteWithError() {
        method_exchangeImplementations(
            class_getInstanceMethod(
                SessionDelegate.self,
                #selector(SessionDelegate.urlSession(_:task:didCompleteWithError:))
            )!,
            class_getInstanceMethod(
                SessionDelegate.self,
                #selector(SessionDelegate.swizzledUrlSessionTaskDidCompleteWithError(_:task:didCompleteWithError:))
            )!
        )
    }

    static func swizzleURLSessionTaskDidSendBodyData() {
        method_exchangeImplementations(
            class_getInstanceMethod(
                SessionDelegate.self,
                #selector(SessionDelegate.urlSession(_:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:))
            )!,
            class_getInstanceMethod(
                SessionDelegate.self,
                #selector(SessionDelegate.swizzledURLSessionDidSendBodyData(_:task:didSendBodyData:totalBytesSent:totalBytesExpectedToSend:))
            )!
        )
    }

    static func swizzleURLSessionWillCacheResponse() {
        method_exchangeImplementations(
            class_getInstanceMethod(
                SessionDelegate.self,
                #selector(SessionDelegate.urlSession(_:dataTask:willCacheResponse:completionHandler:))
            )!,
            class_getInstanceMethod(
                SessionDelegate.self,
                #selector(SessionDelegate.swizzledURLSessionWillCacheResponse(_:dataTask:willCacheResponse:completionHandler:))
            )!
        )
    }

    static func swizzleURLSessionTaskFinishedCollectingMetrics() {
        method_exchangeImplementations(
            class_getInstanceMethod(
                SessionDelegate.self,
                #selector(SessionDelegate.urlSession(_:task:didFinishCollecting:))
            )!,
            class_getInstanceMethod(
                SessionDelegate.self,
                #selector(SessionDelegate.swizzledURLSessionWillCacheResponse(_:dataTask:willCacheResponse:completionHandler:))
            )!
        )
    }

    @objc func swizzledURLSessionDidSendBodyData(_ session: URLSession,
                                  task: URLSessionTask,
                                  didSendBodyData bytesSent: Int64,
                                  totalBytesSent: Int64,
                                  totalBytesExpectedToSend: Int64) {
        self.relatedSession.rootQueue.async {
            self.swizzledURLSessionDidSendBodyData(
                session,
                task: task,
                didSendBodyData: bytesSent,
                totalBytesSent: totalBytesSent,
                totalBytesExpectedToSend: totalBytesExpectedToSend
            )
        }
    }

    @objc func swizzledURLSessionTaskDidReceiveData(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let networkRequest = NetworkRequest(date: Date(), request: dataTask.originalRequest!)
        networkTrafficManager.addRequest(networkRequest)

        networkTrafficManager.pairResponse(
            response: NetworkResponse(date: Date(), response: dataTask.response, data: data, error: dataTask.error),
            with: networkRequest
        )

        self.relatedSession.rootQueue.async {
            self.swizzledURLSessionTaskDidReceiveData(session, dataTask: dataTask, didReceive: data)
        }
    }

    @objc func swizzledUrlSessionTaskDidCompleteWithError(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        defer {
            self.relatedSession.rootQueue.async {
                self.swizzledUrlSessionTaskDidCompleteWithError(session, task: task, didCompleteWithError: error)
            }
        }

        guard let error = error else { return }

        let networkRequest = NetworkRequest(date: Date(), request: task.originalRequest!)
        networkTrafficManager.addRequest(networkRequest)

        networkTrafficManager.pairResponse(
            response: NetworkResponse(date: Date(), response: task.response, data: nil, error: error),
            with: networkRequest
        )
    }

    @objc func swizzledURLSessionWillCacheResponse(_ session: URLSession,
                                              dataTask: URLSessionDataTask,
                                              willCacheResponse proposedResponse: CachedURLResponse,
                                              completionHandler: @escaping (CachedURLResponse?) -> Void) {
        self.relatedSession.rootQueue.async {
            self.swizzledURLSessionWillCacheResponse(
                session,
                dataTask: dataTask,
                willCacheResponse: proposedResponse,
                completionHandler: completionHandler
            )
        }
    }

    @objc func swizzledURLSessionTaskFinishedCollectingMetrics(_ session: URLSession,
                                                               task: URLSessionTask,
                                                               didFinishCollecting metrics: URLSessionTaskMetrics) {
        self.relatedSession.rootQueue.async {
            self.swizzledURLSessionTaskFinishedCollectingMetrics(session, task: task, didFinishCollecting: metrics)
        }
    }
}

extension SessionDelegate {
    var relatedSession: Alamofire.Session {
        let mirror = Mirror(reflecting: self)

        return mirror
            .children
            .filter({ $0.label == "stateProvider" })
            .first!
            .value as! Alamofire.Session
    }
}
