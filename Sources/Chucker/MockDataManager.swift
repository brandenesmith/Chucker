//
//  MockDataManager.swift
//  
//
//  Created by Branden Smith on 4/2/21.
//

import Foundation

final class MockDataManager {
    enum JSONParseError: Error {
        case fileNotFoundInBundle
        case dataCannotBeReadFromFile
        case dataIsNotParsableJSON
    }

    private let config: String
    private let manifest: String
    private let bundle: Bundle
    private let userDefaults: UserDefaults

    internal var workingManifest: MockDataManifest!
    internal var workingConfig: MockDataConfig!

    fileprivate static let apolloOperationTypeHeader = "X-APOLLO-OPERATION-TYPE"
    fileprivate static let apolloOperationNameHeader = "X-APOLLO-OPERATION-NAME"

    internal var mockingEnabled: Bool {
        get {
            return userDefaults.bool(forKey: DefaultsKey.useMockData)
        }
        set {
            userDefaults.set(newValue, forKey: DefaultsKey.useMockData)
        }
    }

    init(config: String, manifest: String, bundle: Bundle, userDefaults: UserDefaults) {
        self.config = config
        self.manifest = manifest
        self.bundle = bundle
        self.userDefaults = userDefaults

        self.workingConfig = try! JSONDecoder().decode(MockDataConfig.self, from: try! data(for: config, in: bundle))
        self.workingManifest = try! JSONDecoder().decode(MockDataManifest.self, from: try! data(for: manifest, in: bundle))
    }

    func mockResponse(for request: URLRequest) throws -> MockResponse {
        let responseKey = workingConfig.included[request.key]!.responseKey

        return MockResponseDecoder()
            .decodeMockResponse(
                from: try! data(
                    for: workingManifest.items[request.key]!.responseMap[responseKey]!,
                    in: bundle
                )
            )
    }

    func shouldMockResponse(for request: URLRequest) -> Bool {
        return !request.key.hasMatchIn(workingConfig.excluded)
            && (workingConfig.included[request.key]?.useMock ?? false)
    }

    private func data(for filename: String, in bundle: Bundle) throws -> Data {
        guard let path = self.bundle.url(forResource: filename, withExtension: "json") else {
            throw JSONParseError.fileNotFoundInBundle
        }

        guard let fileData = try? Data(contentsOf: path, options: .mappedIfSafe) else {
            throw JSONParseError.dataCannotBeReadFromFile
        }

        return fileData
    }

    private func json(for filename: String, in bundle: Bundle) throws -> [String: Any] {
        let data = try self.data(for: filename, in: bundle)

        guard let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            throw JSONParseError.dataIsNotParsableJSON
        }

        return json
    }
}

fileprivate extension String {
    func hasMatchIn(_ excludedList: Set<String>) -> Bool {
        for item in excludedList {
            let regex = try! NSRegularExpression(pattern: item, options: [])
            if !regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count)).isEmpty {
                return true
            }
        }

        return false
    }
}

fileprivate extension URLRequest {
    var key: String {
        let url = self.url!.absoluteString.components(separatedBy: "?")[0]

        var key = "\(url)"

        if let method = self.httpMethod { key += method }
        if let opType = self.allHTTPHeaderFields?[MockDataManager.apolloOperationTypeHeader] { key += opType }
        if let opName = self.allHTTPHeaderFields?[MockDataManager.apolloOperationNameHeader] { key += opName }

        return key
    }
}
