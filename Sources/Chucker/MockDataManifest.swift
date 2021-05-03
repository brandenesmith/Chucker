//
//  MockDataManifest.swift
//  
//
//  Created by Branden Smith on 4/6/21.
//

import Foundation

struct ManifestItem: Decodable {
    let endpoint: String
    let method: String
    let operationType: String?
    let operationName: String?
    let responseMap: [String: String]

    var key: String {
        var key = "\(endpoint)\(method)"

        if let opType = operationType { key += opType }
        if let opName = operationName { key += opName }

        return key
    }
}

struct MockDataManifest: Decodable {
    let items: [String: ManifestItem]

    private enum CodingKeys: String, CodingKey {
        case items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let manifestItems: [ManifestItem] = (try? container.decode([ManifestItem].self, forKey: .items)) ?? []
        items = manifestItems.reduce(into: [:], { (result, item) in
            result[item.key] = item
        })
    }
}
