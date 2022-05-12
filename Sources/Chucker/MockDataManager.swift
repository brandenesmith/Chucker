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

    internal var workingConfig: [String: EndpointConfig]

    fileprivate static let apolloOperationTypeHeader = "X-APOLLO-OPERATION-TYPE"
    fileprivate static let apolloOperationNameHeader = "X-APOLLO-OPERATION-NAME"

    init(config: String, manifest: String, bundle: Bundle) {
        self.config = config
        self.manifest = manifest
        self.bundle = bundle
        self.workingConfig = [:]

        let decodedConfig = try! JSONDecoder().decode(MockDataConfig.self, from: try! data(for: config, in: bundle))
        let decodedManifest = try! JSONDecoder().decode(MockDataManifest.self, from: try! data(for: manifest, in: bundle))

        for (key, value) in decodedConfig.included {
            guard let manifestItem = decodedManifest.items[key] else { continue }

            workingConfig[value.sanitizedKeyInfo.key] = EndpointConfig(
                configItem: value,
                manifestItem: manifestItem
            )
        }
    }

    func mockResponse(for request: URLRequest) throws -> MockResponse? {
        let endpoint = KeySanitizer.stripHTTPS(from: request.key)

        guard workingConfig[endpoint] == nil else {
            let shouldMock = workingConfig[endpoint]!.configItem.useMock
            let responseKey = workingConfig[endpoint]!.configItem.responseKey

            if !shouldMock { return nil }

            return MockResponseDecoder()
                .decodeMockResponse(
                    from: try! data(
                        for: workingConfig[endpoint]!.manifestItem.responseMap[responseKey]!,
                        in: bundle
                    )
                )
        }

        var tokenizedEndpoint = endpoint.split(separator: "/")

        for item in workingConfig.keys {
            let pathParamIndicies = workingConfig[item]!.configItem.sanitizedKeyInfo.pathParamIndicies

            guard !pathParamIndicies.isEmpty else { continue }

            let tokenizedItem = item.split(separator: "/")

            guard tokenizedItem.count == tokenizedEndpoint.count - pathParamIndicies.count else { continue }

            for index in pathParamIndicies {
                tokenizedEndpoint.remove(at: index)
            }

            let joinedKey = tokenizedEndpoint.joined(separator: "")
            let joinedItem = tokenizedItem.joined(separator: "")

            if joinedKey == joinedItem {
                let shouldMock = workingConfig[joinedKey]!.configItem.useMock
                let responseKey = workingConfig[joinedKey]!.configItem.responseKey

                if !shouldMock { return nil }

                return MockResponseDecoder()
                    .decodeMockResponse(
                        from: try! data(
                            for: workingConfig[joinedKey]!.manifestItem.responseMap[responseKey]!,
                            in: bundle
                        )
                    )
            }
        }

        return nil
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
