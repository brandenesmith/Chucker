//
//  ConfigItemPickerViewManager.swift
//  
//
//  Created by Branden Smith on 5/4/21.
//

import Foundation
import UIKit

protocol ConfigItemPickerViewManagerDelegate: AnyObject {
    func configItemManager(didSelectResponseKey key: String, for managedItemKey: String)
}

final class ConfigItemPickerViewManager: NSObject {
    private(set) var selectedIndex: Int

    private let managedItemKey: String
    private weak var delegate: ConfigItemPickerViewManagerDelegate?

    private let pickerItems: [String]

    var isEditing: Bool = false

    init(managedItem: MockDataConfigItem, delegate: ConfigItemPickerViewManagerDelegate) {
        self.managedItemKey = managedItem.sanitizedKeyInfo.key
        self.delegate = delegate

        self.pickerItems = networkTrafficManager
            .mockDataManager!
            .workingConfig[managedItemKey]!
            .manifestItem
            .responseMap
            .keys
            .sorted(by: { $0 < $1 })

        self.selectedIndex = self.pickerItems.firstIndex(where: { $0 == managedItem.responseKey })!

        super.init()
    }
}

extension ConfigItemPickerViewManager: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerItems.count
    }
}

extension ConfigItemPickerViewManager: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerItems[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedIndex = row
        isEditing = false
        delegate?.configItemManager(didSelectResponseKey: pickerItems[row], for: managedItemKey)
    }
}
