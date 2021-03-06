//
//  NetworkTrafficManager.swift
//  Chucker
//
//  Created by Branden Smith on 3/26/21.
//

import Alamofire
import Apollo
import Foundation

struct NetworkRequest: Equatable, Hashable {
    let date: Date
    let request: URLRequest
}

struct NetworkResponse {
    let date: Date
    let response: URLResponse?
    let data: Data?
    let error: Error?
}

struct NetworkListItem {
    let request: NetworkRequest
    let response: NetworkResponse?
}

final class NetworkTrafficManager {
    internal static let shared = NetworkTrafficManager()

    @Published internal var logItems: [NetworkListItem] = []
    internal var mockDataManager: MockDataManager?

    internal var shouldRecord: Bool {
        didSet {
            performSwizzling()
        }
    }

    private var _trafficItems: [NetworkListItem] {
        return trafficLog
            .map({ NetworkListItem(request: $0, response: $1) })
            .sorted(by: { $0.request.date.compare($1.request.date) == .orderedDescending })
    }

    private var trafficLog: [NetworkRequest: NetworkResponse?]

    private init() {
        self.trafficLog = [:]

        if CommandLine.arguments.contains("--chucker-auto-record") {
            shouldRecord = true
            performSwizzling()
        } else {
            shouldRecord = false
        }
    }

    internal func addRequest(_ request: NetworkRequest) {
        trafficLog[request] = nil
        logItems = _trafficItems
    }

    internal func pairResponse(response: NetworkResponse, with request: NetworkRequest) {
        trafficLog[request] = response
        logItems = _trafficItems
    }

    private func performSwizzling() {
        URLSessionDataTask.swizzleResume()
        URLSession.swizzleDataTaskWithRequestCompletion()
        URLSession.swizzleDataTaskWithRequest()
        SessionDelegate.swizzleURLSessionTaskDidReceiveData()
        SessionDelegate.swizzleURLSessionTaskDidCompleteWithError()
        SessionDelegate.swizzleURLSessionTaskDidSendBodyData()
        SessionDelegate.swizzleURLSessionWillCacheResponse()
        SessionDelegate.swizzleURLSessionTaskFinishedCollectingMetrics()
        URLSessionClient.swizzleURLSessionTaskDidReceiveData()
        URLSessionClient.swizzleURLSessionTaskDidCompleteWithError()
    }
}
