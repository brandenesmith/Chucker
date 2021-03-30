//
//  ChuckerViewController.swift
//  Chucker
//
//  Created by Branden Smith on 3/26/21.
//

import Combine
import Foundation
import UIKit

internal let networkTrafficManager = NetworkTrafficManager.shared

public final class ChuckerViewController: UIViewController {
    @IBOutlet weak var recordSwitch: UISwitch!
    @IBOutlet weak var tableView: UITableView!

    private lazy var noItemsView: NoItemsView = {
        let noItemsView = Bundle
            .module
            .loadNibNamed(NoItemsView.nibName, owner: nil, options: nil)!
            .first as! NoItemsView

        noItemsView.frame = self.tableView.bounds

        return noItemsView
    }()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .long

        return formatter
    }()

    private var logItemsStream: AnyCancellable?
    private var tableItems: [NetworkListItem] = []
    
    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    internal required init?(coder: NSCoder) { super.init(coder: coder) }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.recordSwitch.isOn = networkTrafficManager.shouldRecord
        
        tableView.register(
            UINib(nibName: "NetworkListItemCell", bundle: Bundle.module),
            forCellReuseIdentifier: "NetworkListItemCell"
        )

        setupLogItemsSubscription()
    }

    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? NetworkItemDetailViewController else { return }
        guard let item = sender as? NetworkListItem else { return }

        destination.networkListItem = item
    }

    private func setupLogItemsSubscription() {
        logItemsStream = networkTrafficManager
            .$logItems
            .sink(receiveValue: { items in
                self.tableItems = items

                DispatchQueue.main.async {
                    if items.isEmpty {
                        self.addNoItemsView()
                    } else {
                        self.removeNoItemsView()
                        self.tableView.reloadData()
                    }
                }
            })
    }

    private func addNoItemsView() {
        DispatchQueue.main.async {
            self.removeNoItemsView()
            self.tableView.addSubview(self.noItemsView)
            self.tableView.bringSubviewToFront(self.noItemsView)
        }
    }

    private func removeNoItemsView() {
        noItemsView.removeFromSuperview()
    }

    @IBAction func recordSwitchValueChanged(_ sender: UISwitch) {
        networkTrafficManager.shouldRecord = sender.isOn
    }
}

public extension ChuckerViewController {
    static func make() -> ChuckerViewController {
        return UIStoryboard(
            name: "Chucker",
            bundle: Bundle.module
        ).instantiateInitialViewController() as! ChuckerViewController
    }
}

extension ChuckerViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableItems.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NetworkListItemCell") as! NetworkListItemCell
        let item = tableItems[indexPath.row]

        cell.dateLabel.text = self.dateFormatter.string(from: item.request.date)

        if let url = item.request.request.url {
            cell.endpointLabel.text = url.absoluteString
        } else {
            cell.endpointLabel.text = "{none}"
        }

        if let response = item.response?.response as? HTTPURLResponse {
            if  (200...299) ~= response.statusCode {
                cell.iconView.image = UIImage(systemName: "checkmark.circle.fill")
                cell.iconView.tintColor = .systemGreen
            } else {
                cell.iconView.image = UIImage(systemName: "xmark.octagon.fill")
                cell.iconView.tintColor = .systemRed
            }
        }

        if item.response?.error != nil {
            cell.iconView.image = UIImage(systemName: "xmark.octagon.fill")
            cell.iconView.tintColor = .systemRed
        }

        return cell
    }
}

extension ChuckerViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showDetail", sender: tableItems[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
