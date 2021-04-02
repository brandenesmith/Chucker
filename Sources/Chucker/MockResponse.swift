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
}
