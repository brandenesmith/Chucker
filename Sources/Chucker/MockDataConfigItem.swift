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

    let useMock: Bool
    let type: ConfigType
}

struct MockDataConfig: Decodable {
    let items: [String: MockDataConfigItem]

    private struct DynamicCodingKeys: CodingKey {
        var intValue: Int?
        var stringValue: String

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        init?(intValue: Int) {
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)

        items = try container.allKeys.reduce(into: [:], { (result, key) in
            let item = try container.decode(MockDataConfigItem.self, forKey: DynamicCodingKeys.init(stringValue: key.stringValue)!)
            result[key.stringValue] = item
        })
    }
}
