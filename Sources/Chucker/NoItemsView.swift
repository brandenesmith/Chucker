//
//  NoItemsView.swift
//  Chucker
//
//  Created by Branden Smith on 3/26/21.
//

import Foundation
import UIKit

final class NoItemsView: UIView {
    @IBOutlet weak var descriptionLabel: UILabel!
}

extension NoItemsView {
    static let nibName: String = "NoItemsView"
}
