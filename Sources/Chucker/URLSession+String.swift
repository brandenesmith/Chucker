//
//  URLSession+String.swift
//  
//
//  Created by Branden Smith on 3/29/21.
//

import Foundation

extension URLSession {
    static func convertResponseToString(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> NSMutableAttributedString {
        var str = NSMutableAttributedString()

        if let error = error {
            str = str
                .normal("\(error.localizedDescription)\n")
        }

        if let response = response {
            if let httpURLResponse = response as? HTTPURLResponse {
                str = str
                    .bold("Status:")
                    .normal(" \(httpURLResponse.statusCode)")
            }

            if let url = response.url {
                str = str
                    .bold("\nURL:")
                    .normal(" \(url.absoluteString)")
            }

            str = str
                .bold("\nContent Length:")
                .normal(" \(response.expectedContentLength)")

            if let filename = response.suggestedFilename {
                str = str
                    .bold("\nSuggested Filename:")
                    .normal(" \(filename)")
            }

            if let mime = response.mimeType {
                str = str
                    .bold("\nMIME:")
                    .normal(" \(mime)")
            }

            if let encoding = response.textEncodingName {
                str = str
                    .bold("\nText Encoding:")
                    .normal(" \(encoding)")
            }

            if let httpURLResponse = response as? HTTPURLResponse, !httpURLResponse.allHeaderFields.isEmpty {
                str = str.bold("\nHeaders:")

                httpURLResponse.allHeaderFields.forEach({ (header, value) in
                    str = str.normal("\n\t\(header): \(value)")
                })
            }
        }

        if let data = data {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)

                str = str.bold("\n\nBody:")
                str = str.normal("\n\(json)")
            } catch {
                // Do Nothing
            }
        }

        return str
    }
}
