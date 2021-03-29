//
//  NetworkItemDetailViewController.swift
//  Chucker
//
//  Created by Branden Smith on 3/26/21.
//

import Foundation
import UIKit

final class NetworkItemDetailViewController: UIViewController {
    internal var networkListItem: NetworkListItem!
    @IBOutlet weak var requestTextView: UITextView!
    @IBOutlet weak var responseTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        populateRequestTextView()
        populateResponseTextView()
    }

    private func populateRequestTextView() {
        let request = networkListItem.request.request
        requestTextView.attributedText = request.toString()
    }

    private func populateResponseTextView() {
        guard let response = networkListItem.response else {
            responseTextView.attributedText = NSMutableAttributedString()
                .normal("No Data Available")

            return
        }
        
        responseTextView.attributedText = URLSession.convertResponseToString(response.data, response.response, response.error)
    }
}
