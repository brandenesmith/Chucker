//
//  KeySanitizer.swift
//  
//
//  Created by Branden Smith on 5/11/22.
//

import Foundation

final class KeySanitizer {
    static func getSanitizedKeyInfo(key: String) -> SanitizedKeyInfo {
        guard let expression = try? NSRegularExpression(pattern: "\\{.*\\}") else {
            return SanitizedKeyInfo(key: key, pathParamIndicies: [])
        }

        var matches: [Int] = []

        var tokens = key.split(separator: "/")

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

        matches.forEach({ tokens.remove(at: $0) })

        return SanitizedKeyInfo(
            key: tokens.joined(separator: "/"),
            pathParamIndicies: matches
        )
    }

    static func createKey(endpoint: String, method: String, operationName: String?, operationType: String?) -> String {
        var key = "\(KeySanitizer.stripHTTPS(from: endpoint))\(method)"
        if let opType = operationType { key += opType }
        if let opName = operationName { key += opName }

        return key
    }

    static func stripHTTPS(from endpoint: String) -> String {
        guard
            let https = try? NSRegularExpression(pattern: "https://"),
            let http = try? NSRegularExpression(pattern: "http://")
        else {
            return endpoint
        }

        let mutableString = NSMutableString(string: endpoint)

        https.replaceMatches(in: mutableString, range: NSRange(location: 0, length: mutableString.length), withTemplate: "")
        http.replaceMatches(in: mutableString, range: NSRange(location: 0, length: mutableString.length), withTemplate: "")

        return String(mutableString)
    }
}

struct SanitizedKeyInfo: Hashable {
    let key: String
    let pathParamIndicies: [Int]
}

