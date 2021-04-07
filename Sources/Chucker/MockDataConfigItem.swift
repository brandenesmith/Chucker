//
//  MockDataConfigItem.swift
//  
//
//  Created by Branden Smith on 4/6/21.
//

import Foundation

struct MockDataConfigItem: Decodable, Hashable {
    enum ConfigType: String, Decodable {
        case success
        case failure
    }

    let endpoint: String
    let useMock: Bool
    let type: ConfigType
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
            result[item.endpoint] = item
        })

        let excludedItems: [String] = try container.decodeIfPresent([String].self, forKey: .excluded) ?? []
        excluded = Set(excludedItems)
    }
}
