//
//  MockDataConfigItemCell.swift
//  
//
//  Created by Branden Smith on 5/4/21.
//

import Foundation
import UIKit

protocol MockDataConfigItemCellDelegate: AnyObject {
    func configItemCellIsEditingResponseKey(_ cell: MockDataConfigItemCell)
    func configItemCell(_ cell: MockDataConfigItemCell, valueForUseMockChangedTo newValue: Bool)
}

final class MockDataConfigItemCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var endpointLabel: UILabel!
    @IBOutlet weak var methodLabel: UILabel!
    @IBOutlet weak var operationTypeLabel: UILabel!
    @IBOutlet weak var operationNameLabel: UILabel!
    @IBOutlet weak var useMockLabel: UILabel!
    @IBOutlet weak var useMockSwitch: UISwitch!
    @IBOutlet weak var responseKeyLabel: UILabel!

    weak var delegate: MockDataConfigItemCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        useMockSwitch.addTarget(self, action: #selector(useMockSwitchValueChanged(_:)), for: .valueChanged)

        responseKeyLabel.isUserInteractionEnabled = true
        responseKeyLabel.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(responseKeyLabelTapped(_:)))
        )
    }

    @objc private func responseKeyLabelTapped(_ sender: UITapGestureRecognizer) {
        delegate?.configItemCellIsEditingResponseKey(self)
    }

    @objc private func useMockSwitchValueChanged(_ sender: UISwitch) {
        delegate?.configItemCell(self, valueForUseMockChangedTo: sender.isOn)
    }
}
