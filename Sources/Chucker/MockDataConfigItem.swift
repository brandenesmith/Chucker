//
//  MockDataConfigItem.swift
//  
//
//  Created by Branden Smith on 4/6/21.
//

import Foundation

enum ConfigType: String, Decodable {
    case success
    case failure
}

struct MockDataConfigItem: Decodable, Hashable {
    let endpoint: String
    let useMock: Bool
    let type: ConfigType
}

struct GraphQLMockDataConfigItem: Decodable {
    enum OperationType: String, Decodable, Hashable {
        case query
        case mutation
    }

    let endpoint: String
    let operationType: OperationType
    let operationName: String
    let useMock: Bool
    let type: ConfigType

    var key: String {
        return "\(endpoint)\(operationType.rawValue)\(operationName)"
            .replacingOccurrences(of: "/", with: "")
    }
}

struct GraphQLExclusion: Decodable, Hashable {
    let endpoint: String
    let operationType: GraphQLMockDataConfigItem.OperationType
    let operationName: String
}

struct MockDataConfig: Decodable {
    let included: [String: MockDataConfigItem]
    let includedGraphQL: [String: GraphQLMockDataConfigItem]
    let excluded: Set<String>
    let excludedGraphQL: Set<GraphQLExclusion>

    enum CodingKeys: String, CodingKey {
        case included
        case includedGraphQL
        case excluded
        case excludedGraphQL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let includedItems = try container.decode([MockDataConfigItem].self, forKey: .included)
        included = includedItems.reduce(into: [:], { (result, item) in
            result[item.endpoint] = item
        })

        let includedGraphQLItems = (try? container.decodeIfPresent([GraphQLMockDataConfigItem].self, forKey: .includedGraphQL)) ?? []
        includedGraphQL = includedGraphQLItems.reduce(into: [:], { (result, item) in
            result[item.key] = item
        })

        let excludedItems: [String] = try container.decodeIfPresent([String].self, forKey: .excluded) ?? []
        excluded = Set(excludedItems)

        let excludedGraphQLItems = (try? container.decodeIfPresent([GraphQLExclusion].self, forKey: .excludedGraphQL)) ?? []
        excludedGraphQL = Set(excludedGraphQLItems)
    }
}
