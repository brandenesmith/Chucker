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

    private let manifest: String
    private let bundle: Bundle

    private var workingManifest: [String: [String: String]]!

    init(manifest: String, bundle: Bundle) {
        self.manifest = manifest
        self.bundle = bundle

        self.workingManifest = (try! json(for: manifest, in: bundle) as! [String: [String: String]])
    }


    func mockResponse(for url: String, type: String = "success") throws -> MockResponse {
        return MockResponseDecoder().decodeMockResponse(from: try! data(for: workingManifest[url]![type]!, in: bundle))
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
