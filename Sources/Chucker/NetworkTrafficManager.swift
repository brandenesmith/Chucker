//
//  NetworkTrafficManager.swift
//  Chucker
//
//  Created by Branden Smith on 3/26/21.
//

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

    internal var shouldRecord: Bool = false {
        didSet {
            URLSessionDataTask.swizzleResume()
            URLSession.swizzleDataTaskWithRequest()
            URLSession.swizzleDataTaskWithRequestCompletion()
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
    }

    internal func addRequest(_ request: NetworkRequest) {
        trafficLog[request] = nil
        logItems = _trafficItems
    }

    internal func pairResponse(response: NetworkResponse, with request: NetworkRequest) {
        trafficLog[request] = response
        logItems = _trafficItems
    }
}
