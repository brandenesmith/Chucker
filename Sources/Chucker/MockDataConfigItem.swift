//
//  MockDataConfigItem.swift
//  
//
//  Created by Branden Smith on 4/6/21.
//

import Foundation

struct MockDataConfigItem: Decodable, Hashable {
    enum CodingKeys: String, CodingKey {
        case name
        case endpoint
        case method
        case operationName
        case operationType
        case useMock
        case responseKey
    }

    let name: String
    let endpoint: String
    let method: String
    let operationName: String?
    let operationType: String?
    let useMock: Bool
    let responseKey: String
    let key: String
    let sanitizedKeyInfo: SanitizedKeyInfo

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)
        endpoint = try container.decode(String.self, forKey: .endpoint)
        method = try container.decode(String.self, forKey: .method)
        operationName = try container.decode(String?.self, forKey: .operationName)
        operationType = try container.decode(String?.self, forKey: .operationType)
        useMock = try container.decode(Bool.self, forKey: .useMock)
        responseKey = try container.decode(String.self, forKey: .responseKey)
        

        self.key = KeySanitizer.createKey(endpoint: endpoint, method: method, operationName: operationName, operationType: operationType)
        self.sanitizedKeyInfo = KeySanitizer.getSanitizedKeyInfo(key: key)
    }

    init(name: String, endpoint: String, method: String, operationName: String?, operationType: String?, useMock: Bool, responseKey: String) {
        self.name = name
        self.endpoint = endpoint
        self.method = method
        self.operationName = operationName
        self.operationType = operationType
        self.useMock = useMock
        self.responseKey = responseKey
        
        self.key = KeySanitizer.createKey(endpoint: endpoint, method: method, operationName: operationName, operationType: operationType)
        self.sanitizedKeyInfo = KeySanitizer.getSanitizedKeyInfo(key: key)
    }
}

struct MockDataConfig: Decodable {
    var included: [String: MockDataConfigItem]
    var excluded: Set<String>

    enum CodingKeys: String, CodingKey {
        case included
        case excluded
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let includedItems = try container.decode([MockDataConfigItem].self, forKey: .included)
        included = includedItems.reduce(into: [:], { (result, item) in
            result[item.key] = item
        })

        let excludedItems: [String] = try container.decodeIfPresent([String].self, forKey: .excluded) ?? []
        excluded = Set(excludedItems)
    }

    func included(key: String) -> MockDataConfigItem? {
        guard included[key] == nil else { return included[key] }

        var tokenizedKey = key.split(separator: "/")

        for item in included.keys {
            let pathParamIndicies = getPathParamIndicies(key: item)

            guard !pathParamIndicies.isEmpty else { continue }

            var tokenizedItem = item.split(separator: "/")

            guard tokenizedItem.count == tokenizedKey.count else { continue }

            for index in pathParamIndicies {
                tokenizedKey.remove(at: index)
                tokenizedItem.remove(at: index)
            }

            if tokenizedKey.joined(separator: "") == tokenizedItem.joined(separator: "") {
                return included[item]
            }
        }

        return nil
    }

    private func getPathParamIndicies(key: String) -> [Int] {
        guard let expression = try? NSRegularExpression(pattern: "\\{.*\\}") else { return [] }

        var matches: [Int] = []

        let tokens = key.split(separator: "/")

        tokens.map({ String($0) }).enumerated().forEach({ elmt in
            let matchInicies = expression.matches(
                in: elmt.element,
                options: .reportCompletion,
                range: NSRange(location: 0, length: elmt.element.count)
            )

            if !matchInicies.isEmpty {
                matches.append(elmt.offset)
            }
        })

        return matches
    }
}
