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

    @IBOutlet weak var requestTextViewHeight: NSLayoutConstraint!
    @IBOutlet weak var responseTextViewHeight: NSLayoutConstraint!

    private var initialRequestTextViewHeight: CGFloat!
    private var initialResponseTextViewHeight: CGFloat!

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
        self.initialRequestTextViewHeight = requestTextViewHeight.constant
        let request = networkListItem.request.request
        requestTextView.attributedText = request.toString()
    }

    private func populateResponseTextView() {
        self.initialResponseTextViewHeight = responseTextViewHeight.constant
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
                if self.requestIsOpen {
                    self.requestTextViewHeight.constant = self.initialRequestTextViewHeight
                    self.requestButton.imageView?.transform = self.requestButton.imageView!.transform.rotated(by: .pi / 2.0)
                } else {
                    self.requestTextViewHeight.constant = 0.0
                    self.requestButton.imageView?.transform = self.requestButton.imageView!.transform.rotated(by: (.pi / 2.0) * -1.0)
                }
            case .response:
                if self.responseIsOpen {
                    self.responseTextViewHeight.constant = self.initialResponseTextViewHeight
                    self.responseButton.imageView?.transform = self.responseButton.imageView!.transform.rotated(by: .pi / 2.0)
                } else {
                    self.responseTextViewHeight.constant = 0.0
                    self.responseButton.imageView?.transform = self.responseButton.imageView!.transform.rotated(by: (.pi / 2.0) * -1.0)
                }
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
