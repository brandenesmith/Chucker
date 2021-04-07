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

    init(config: String, manifest: String, bundle: Bundle) {
        self.config = config
        self.manifest = manifest
        self.bundle = bundle

        self.workingConfig = try! JSONDecoder().decode(MockDataConfig.self, from: try! data(for: config, in: bundle))
        self.workingManifest = try! JSONDecoder().decode(MockDataManifest.self, from: try! data(for: manifest, in: bundle))
    }

    func shouldMockResponse(for url: String) throws -> Bool {
        return !workingConfig.excluded.contains(url)
            && (workingConfig.included[url]?.useMock ?? false)
    }

    func mockResponse(for url: String) throws -> MockResponse {
        return MockResponseDecoder()
            .decodeMockResponse(
                from: try! data(
                    for: workingManifest.items[url]!.value(
                        for: workingConfig.included[url]!.type
                    ),
                    in: bundle
                )
            )
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
