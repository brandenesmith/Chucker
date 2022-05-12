//
//  EditMockDataConfigViewController.swift
//  
//
//  Created by Branden Smith on 5/4/21.
//

import Foundation
import UIKit

final class EditMockDataConfigViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    private lazy var items: [EndpointConfig] = {
        return networkTrafficManager
            .mockDataManager!
            .workingConfig
            .values
            .sorted(by: { $0.configItem.name < $1.configItem.name })
    }()

    private lazy var pickerManagers: [ConfigItemPickerViewManager] = {
        return items.map({ ConfigItemPickerViewManager(managedItem: $0.configItem, delegate: self) })
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Config"
        
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.register(
            UINib(nibName: "MockDataConfigItemCell", bundle: Bundle.module),
            forCellReuseIdentifier: "MockDataConfigItemCell"
        )

        tableView.register(
            UINib(
                nibName: "PickerCell",
                bundle: Bundle.module
            ),
            forCellReuseIdentifier: "PickerCell"
        )
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
}

extension EditMockDataConfigViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return networkTrafficManager.mockDataManager!.workingConfig.count * 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row % 2 == 0 {
            return configureMockDataConfigItemCell(for: tableView, at: indexPath)
        } else {
            return configurePcikerCell(for: tableView, at: indexPath)
        }
    }

    private func configureMockDataConfigItemCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MockDataConfigItemCell") as! MockDataConfigItemCell
        let index = convertIndex(indexPath.row)

        let item = items[index]

        cell.delegate = self

        cell.nameLabel.text = item.configItem.name
        cell.endpointLabel.text = item.configItem.endpoint
        cell.methodLabel.text = item.configItem.method

        cell.operationTypeLabel.isHidden = item.configItem.operationType == nil
        cell.operationTypeLabel.text = item.configItem.operationType

        cell.operationNameLabel.isHidden = item.configItem.operationName == nil
        cell.operationNameLabel.text = item.configItem.operationName

        cell.useMockLabel.text = "Use Mock Data"
        cell.useMockSwitch.isOn = item.configItem.useMock

        cell.responseKeyLabel.text = "Response Key: \(item.configItem.responseKey)"

        return cell
    }

    private func configurePcikerCell(for tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PickerCell") as! PickerCell
        let index = convertIndex(indexPath.row)

        cell.pickerView.dataSource = pickerManagers[index]
        cell.pickerView.delegate = pickerManagers[index]
        cell.pickerView.isHidden = !pickerManagers[index].isEditing

        cell.pickerView.selectRow(
            pickerManagers[index].selectedIndex,
            inComponent: 0,
            animated: false
        )

        return cell
    }

    func convertIndex(_ index: Int) -> Int {
        return index / 2
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 2 == 0 {
            return UITableView.automaticDimension
        } else {
            return pickerManagers[convertIndex(indexPath.row)].isEditing ? 104.0 : 0.0
        }
    }
}

extension EditMockDataConfigViewController: UITableViewDelegate {

}

extension EditMockDataConfigViewController: ConfigItemPickerViewManagerDelegate {
    func configItemManager(didSelectResponseKey key: String, for managedItemKey: String) {
        let originalItem = networkTrafficManager.mockDataManager!.workingConfig[managedItemKey]!
        let newItem = MockDataConfigItem(
            name: originalItem.configItem.name,
            endpoint: originalItem.configItem.endpoint,
            method: originalItem.configItem.method,
            operationName: originalItem.configItem.operationName,
            operationType: originalItem.configItem.operationType,
            useMock: originalItem.configItem.useMock,
            responseKey: key
        )

        let newConfig = EndpointConfig(
            configItem: newItem,
            manifestItem: originalItem.manifestItem
        )

        networkTrafficManager.mockDataManager?.workingConfig[managedItemKey] = newConfig

        let itemIndex = items.firstIndex(where: { $0.configItem.key == managedItemKey })!
        items[itemIndex] = newConfig

        tableView.reloadRows(at: [IndexPath(row: itemIndex, section: 0)], with: .automatic)
    }
}

extension EditMockDataConfigViewController: MockDataConfigItemCellDelegate {
    func configItemCellIsEditingResponseKey(_ cell: MockDataConfigItemCell) {
        let cellIndex = tableView.indexPath(for: cell)!.row
        let pickerIndex = IndexPath(row: cellIndex + 1, section: 0)

        pickerManagers[convertIndex(cellIndex)].isEditing = true
        (tableView.reloadRows(at: [pickerIndex], with: .automatic))
    }

    func configItemCell(_ cell: MockDataConfigItemCell, valueForUseMockChangedTo newValue: Bool) {
        let index = convertIndex(tableView.indexPath(for: cell)!.row)
        let originalItem = items[index]
        let newItem = MockDataConfigItem(
            name: originalItem.configItem.name,
            endpoint: originalItem.configItem.endpoint,
            method: originalItem.configItem.method,
            operationName: originalItem.configItem.operationName,
            operationType: originalItem.configItem.operationType,
            useMock: newValue,
            responseKey: originalItem.configItem.responseKey
        )

        networkTrafficManager.mockDataManager?.workingConfig[originalItem.configItem.sanitizedKeyInfo.key] = EndpointConfig(
            configItem: newItem,
            manifestItem: originalItem.manifestItem
        )
    }
}
