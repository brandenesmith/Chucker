//
//  MockDataConfigItem.swift
//  
//
//  Created by Branden Smith on 4/6/21.
//

import Foundation

struct MockDataConfigItem: Decodable, Hashable {
    let endpoint: String
    let method: String
    let operationName: String?
    let operationType: String?
    let useMock: Bool
    let responseKey: String

    var key: String {
        var key = "\(endpoint)\(method)"

        if let opType = operationType { key += opType }
        if let opName = operationName { key += opName }

        return key
    }
}

struct MockDataConfig: Decodable {
    let included: [String: MockDataConfigItem]
    let excluded: Set<String>

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
}
