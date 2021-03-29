//
//  NSMutableAttributedString+.swift
//  Chucker
//
//  Created by Branden Smith on 3/29/21.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    fileprivate static let boldFont = UIFont.boldSystemFont(ofSize: 16.0)
    fileprivate static let normalFont = UIFont.systemFont(ofSize: 14.0)

    func bold(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSMutableAttributedString.boldFont,
            .foregroundColor: UIColor.label
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))

        return self
    }

    func normal(_ value: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [
            .font : NSMutableAttributedString.normalFont,
            .foregroundColor: UIColor.label
        ]

        self.append(NSAttributedString(string: value, attributes:attributes))
        
        return self
    }
}
