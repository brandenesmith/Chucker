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
    @IBOutlet weak var requestButton: UIButton!
    @IBOutlet weak var responseButton: UIButton!

    private var requestIsOpen: Bool = true {
        didSet {
            updateViewForStateChange(.request)
        }
    }

    private var responseIsOpen: Bool = true {
        didSet {
            updateViewForStateChange(.response)
        }
    }

    private enum StateChange {
        case request
        case response
    }

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

    private func updateViewForStateChange(_ change: StateChange) {
        UIView.animate(withDuration: 0.25, animations: {
            switch change {
            case .request:
                self.requestButton.imageView?.transform = CGAffineTransform(
                    rotationAngle: (self.requestIsOpen)
                        ? CGFloat(Double.pi / 4.0)
                        : CGFloat((Double.pi / 4.0) * -1)
                )
            case .response:
                self.responseButton.imageView?.transform = CGAffineTransform(
                    rotationAngle: (self.responseIsOpen)
                        ? CGFloat(Double.pi / 4.0)
                        : CGFloat((Double.pi / 4.0) * -1)
                )
            }
        })
    }

    @IBAction private func requestButtonTouched(_ sender: UIButton) {
        requestIsOpen.toggle()
    }

    @IBAction private func responseButtonTouched(_ sender: UIButton) {
        responseIsOpen.toggle()
    }
}
