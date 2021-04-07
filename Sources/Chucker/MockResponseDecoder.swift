//
//  MockResponseDecoder.swift
//  
//
//  Created by Branden Smith on 4/5/21.
//

import Foundation

final class MockResponseDecoder: JSONDecoder {
    func decodeMockResponse(from data: Data) -> MockResponse {
        let response = try! JSONDecoder().decode(MockResponse.self, from: data)

        return MockResponse(
            url: response.url,
            statusCode: response.statusCode,
            httpVersion: response.httpVersion,
            headerFields: response.headerFields,
            body: extractBodyData(from: data)
        )
    }

    private func extractBodyData(from data: Data) -> Data? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
            let body = json["body"]!

            if let bodyJSON = try? JSONSerialization.data(withJSONObject: body, options: .sortedKeys) {
                return bodyJSON
            } else if let bodyText = (body as? String)?.data(using: .utf8) {
                return bodyText
            } else {
                return nil
            }
        }

        return nil
    }
}
