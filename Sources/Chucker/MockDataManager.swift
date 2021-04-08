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

    private var workingManifest: MockDataManifest!
    private var workingConfig: MockDataConfig!

    private let apolloOperationTypeHeader = "X-APOLLO-OPERATION-TYPE"
    private let apolloOperationNameHeader = "X-APOLLO-OPERATION-NAME"

    init(config: String, manifest: String, bundle: Bundle) {
        self.config = config
        self.manifest = manifest
        self.bundle = bundle

        self.workingConfig = try! JSONDecoder().decode(MockDataConfig.self, from: try! data(for: config, in: bundle))
        self.workingManifest = try! JSONDecoder().decode(MockDataManifest.self, from: try! data(for: manifest, in: bundle))
    }

    func shouldMockResponse(for request: URLRequest) throws -> Bool {
        return shouldMockREST(for: request.url!.absoluteString.components(separatedBy: "?")[0])
            || shouldMockGraphQL(for: request)
    }

    func mockResponse(for request: URLRequest) throws -> MockResponse {
        let endpoint = request.url!.absoluteString.components(separatedBy: "?")[0]

        if let graphQLOperationType = request.allHTTPHeaderFields?[apolloOperationTypeHeader],
           let graphQLOperationName = request.allHTTPHeaderFields?[apolloOperationNameHeader] {
            return MockResponseDecoder()
                .decodeMockResponse(
                    from: try! data(
                        for: workingManifest.items[endpoint + graphQLOperationType + graphQLOperationName]!.value(
                            for: workingConfig.includedGraphQL[endpoint + graphQLOperationType + graphQLOperationName]!.type
                        ),
                        in: bundle
                    )
                )
        } else {
            return MockResponseDecoder()
                .decodeMockResponse(
                    from: try! data(
                        for: workingManifest.items[endpoint]!.value(
                            for: workingConfig.included[endpoint]!.type
                        ),
                        in: bundle
                    )
                )
        }
    }

    private func shouldMockREST(for url: String) -> Bool {
        return !url.hasMatchIn(workingConfig.excluded)
            && (workingConfig.included[url]?.useMock ?? false)
    }

    private func shouldMockGraphQL(for request: URLRequest) -> Bool {
        guard let operationType = request.allHTTPHeaderFields?[apolloOperationTypeHeader] else { return false }
        guard let opertationName = request.allHTTPHeaderFields?[apolloOperationNameHeader] else { return false }

        let endpoint = request.url!.absoluteString.components(separatedBy: "?")[0]
        let graphQLKey = endpoint
            + operationType
            + opertationName

        return !workingConfig.excludedGraphQL.contains(
            where: { (item) in
                item == GraphQLExclusion(
                    endpoint: endpoint,
                    operationType: GraphQLMockDataConfigItem.OperationType.init(rawValue: operationType)!,
                    operationName: opertationName
                )}
        )
        && (workingConfig.includedGraphQL[graphQLKey]?.useMock ?? false)
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
