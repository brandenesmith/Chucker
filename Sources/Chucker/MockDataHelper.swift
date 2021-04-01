//
//  MockDataHelper.swift
//  
//
//  Created by Branden Smith on 4/1/21.
//

import Foundation

final class MockDataHelper {
    static func parseParams(from query: String?) -> [String: Any]? {
        guard let query = query else { return nil }

        var dict: [String: Any] = [:]

        let seperatedQuery = query.split(separator: "&").map({ String($0) })

        seperatedQuery.forEach({ param in
            let pair = param.split(separator: "=").map({ String($0) })
            dict[pair[0]] = pair[1]
        })

        return dict
    }
}
