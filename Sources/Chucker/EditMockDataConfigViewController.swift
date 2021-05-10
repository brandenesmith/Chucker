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

    private lazy var items: [MockDataConfigItem] = {
        return networkTrafficManager
            .mockDataManager!
            .workingConfig
            .included
            .values
            .sorted(by: { $0.name < $1.name })
    }()

    private lazy var pickerManagers: [ConfigItemPickerViewManager] = {
        return items.map({ ConfigItemPickerViewManager(managedItem: $0, delegate: self) })
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
        return networkTrafficManager.mockDataManager!.workingConfig.included.count * 2
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

        cell.nameLabel.text = item.name
        cell.endpointLabel.text = item.endpoint
        cell.methodLabel.text = item.method

        cell.operationTypeLabel.isHidden = item.operationType == nil
        cell.operationTypeLabel.text = item.operationType

        cell.operationNameLabel.isHidden = item.operationName == nil
        cell.operationNameLabel.text = item.operationName

        cell.useMockLabel.text = "Use Mock Data"
        cell.useMockSwitch.isOn = item.useMock

        cell.responseKeyLabel.text = "Response Key: \(item.responseKey)"

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
        let originalItem = networkTrafficManager.mockDataManager!.workingConfig.included[managedItemKey]!
        let newItem = MockDataConfigItem(
            name: originalItem.name,
            endpoint: originalItem.endpoint,
            method: originalItem.method,
            operationName: originalItem.operationName,
            operationType: originalItem.operationType,
            useMock: originalItem.useMock,
            responseKey: key
        )

        networkTrafficManager.mockDataManager?.workingConfig.included[managedItemKey] = newItem

        let itemIndex = items.firstIndex(where: { $0.key == managedItemKey })!
        items[itemIndex] = newItem

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
            name: originalItem.name,
            endpoint: originalItem.endpoint,
            method: originalItem.method,
            operationName: originalItem.operationName,
            operationType: originalItem.operationType,
            useMock: newValue,
            responseKey: originalItem.responseKey
        )

        networkTrafficManager.mockDataManager?.workingConfig.included[originalItem.key] = newItem
    }
}
