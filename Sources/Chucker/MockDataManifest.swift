//
//  MockDataManifest.swift
//  
//
//  Created by Branden Smith on 4/6/21.
//

import Foundation

struct ManifestItem: Decodable {
    let success: String
    let failure: String

    func value(for configType: MockDataConfigItem.ConfigType) -> String {
        switch configType {
        case .success:
            return success
        case .failure:
            return failure
        }
    }
}

struct MockDataManifest: Decodable {
    let items: [String: ManifestItem]

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
            let item = try container.decode(ManifestItem.self, forKey: DynamicCodingKeys(stringValue: key.stringValue)!)
            result[key.stringValue] = item
        })
    }
}
