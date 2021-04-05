//
//  MockResponse.swift
//  
//
//  Created by Branden Smith on 4/2/21.
//

import Foundation

struct MockResponse: Decodable {
    let url: String
    let statusCode: Int
    let httpVersion: String?
    let headerFields: [String: String]
    let body: Data?

    enum CodingKeys: String, CodingKey {
        case url
        case statusCode
        case httpVersion
        case headerFields
    }

    init(url: String, statusCode: Int, httpVersion: String?, headerFields: [String: String], body: Data?) {
        self.url = url
        self.statusCode = statusCode
        self.httpVersion = httpVersion
        self.headerFields = headerFields
        self.body = body
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        url = try container.decode(String.self, forKey: .url)
        statusCode = try container.decode(Int.self, forKey: .statusCode)
        httpVersion = try container.decodeIfPresent(String.self, forKey: .httpVersion)
        headerFields = try container.decode([String: String].self, forKey: .headerFields)

        // Setting body to nil here because its type is not known.
        // this initializer is for internal use only. Decoding instances
        // of MockResponse should use the MockResponseDecoder.
        body = nil
    }
}
