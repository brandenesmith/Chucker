//
//  URLRequest+String.swift
//  Chucker
//
//  Created by Branden Smith on 3/29/21.
//

import Foundation

extension URLRequest {
    func toString() -> NSMutableAttributedString {
        var str = NSMutableAttributedString()

        if let method = self.httpMethod {
            str = str.bold(method)
        }

        if let url = self.url {
            str = str.normal(": \(url.absoluteString)")
        }

        str = str
            .bold("\nCache Policy:")
            .normal(" \(self.cachePolicy)")
            .bold("\nTimeout:")
            .normal(" \(self.timeoutInterval) seconds")
            .bold("\nShould Handle Cookies:")
            .normal(" \(self.httpShouldHandleCookies)")
            .bold("\nShould Use Pipelining:")
            .normal(" \(self.httpShouldUsePipelining)")
            .bold("\nAllows Cellular Access:")
            .normal(" \(self.allowsCellularAccess)")
            .bold("\nAllows Constrained Network Access:")
            .normal(" \(self.allowsConstrainedNetworkAccess)")
            .bold("\nAllows Expensive Network Access:")
            .normal(" \(self.allowsExpensiveNetworkAccess)")
            .bold("\nNetwork Service Type:")
            .normal(" \(self.networkServiceType)")

        if let headers = self.allHTTPHeaderFields {
            str = str.bold("\nHeaders:")

            headers.forEach({ (header, value) in
                str = str.normal("\n\t\(header): \(value)")
            })
        }

        if let body = self.httpBody {
            do {
                let json = try JSONSerialization.jsonObject(with: body, options: .allowFragments)

                str = str.bold("\n\nBody:")
                str = str.normal("\n\(json)")
            } catch {
                print(error)
            }
        }

        return str
    }
}




