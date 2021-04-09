//
//  MockDataManifest.swift
//  
//
//  Created by Branden Smith on 4/6/21.
//

import Foundation

struct ManifestItem: Decodable {
    let endpoint: String
    let success: String
    let failure: String

    func value(for configType: ConfigType) -> String {
        switch configType {
        case .success:
            return success
        case .failure:
            return failure
        }
    }
}

struct GraphQLManifestItem: Decodable {
    let endpoint: String
    let operationType: String
    let operationName: String
    let success: String
    let failure: String

    var key: String {
        return "\(endpoint)\(operationType)\(operationName)"
            .replacingOccurrences(of: "/", with: "")
    }

    func value(for configType: ConfigType) -> String {
        switch configType {
        case .success:
            return success
        case .failure:
            return failure
        }
    }
}

struct MockDataManifest: Decodable {
    let restItems: [String: ManifestItem]
    let graphqlItems: [String: GraphQLManifestItem]

    private enum CodingKeys: String, CodingKey {
        case rest
        case graphql
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let rest: [ManifestItem] = (try? container.decode([ManifestItem].self, forKey: .rest)) ?? []
        restItems = rest.reduce(into: [:], { (result, item) in
            result[item.endpoint] = item
        })

        let graphql: [GraphQLManifestItem] = (try? container.decode([GraphQLManifestItem].self, forKey: .graphql)) ?? []
        graphqlItems = graphql.reduce(into: [:], { (result, item) in
            result[item.key] = item
        })
    }
}
