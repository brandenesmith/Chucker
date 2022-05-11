//
//  MockDataManifest.swift
//  
//
//  Created by Branden Smith on 4/6/21.
//

import Foundation

struct ManifestItem: Decodable {
    let name: String
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

    func included(key: String) -> ManifestItem? {
        guard items[key] == nil else { return items[key] }

        var tokenizedKey = key.split(separator: "/")

        for item in items.keys {
            let pathParamIndicies = getPathParamIndicies(key: item)

            guard !pathParamIndicies.isEmpty else { continue }

            var tokenizedItem = item.split(separator: "/")

            guard tokenizedItem.count == tokenizedKey.count else { continue }

            for index in pathParamIndicies {
                tokenizedKey.remove(at: index)
                tokenizedItem.remove(at: index)
            }

            if tokenizedKey.joined(separator: "") == tokenizedItem.joined(separator: "") {
                return items[item]
            }
        }

        return nil
    }

    private func getPathParamIndicies(key: String) -> [Int] {
        guard let expression = try? NSRegularExpression(pattern: "^\\{.*\\}$") else { return [] }

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
