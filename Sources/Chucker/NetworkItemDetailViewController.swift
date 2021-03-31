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

    private var _requestIsOpen: Bool = true
    private var _responseIsOpen: Bool = true

    private var requestIsOpen: Bool {
        get {
            return _requestIsOpen
        }
        set {
            if !newValue && !responseIsOpen { return }
            _requestIsOpen = newValue
            updateViewForStateChange(.request)
        }
    }

    private var responseIsOpen: Bool {
        get {
            return _responseIsOpen
        }
        set {
            if !newValue && !requestIsOpen { return }
            _responseIsOpen = newValue
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
        switch (self.requestIsOpen, self.responseIsOpen) {
        case (true, true):
            self.requestTextView.isHidden = false
            self.responseTextView.isHidden = false
        case (true, false):
            self.requestTextView.isHidden = false
            self.responseTextView.isHidden = true
        case (false, true):
            self.requestTextView.isHidden = true
            self.responseTextView.isHidden = false
        case (false, false):
            self.requestTextView.isHidden = true
            self.responseTextView.isHidden = true
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            switch change {
            case .request:
                if self.requestIsOpen {
                    self.requestButton.imageView?.transform = self.requestButton.imageView!.transform.rotated(by: .pi / 2.0)
                } else {
                    self.requestButton.imageView?.transform = self.requestButton.imageView!.transform.rotated(by: (.pi / 2.0) * -1.0)
                }
            case .response:
                if self.responseIsOpen {
                    self.responseButton.imageView?.transform = self.responseButton.imageView!.transform.rotated(by: .pi / 2.0)
                } else {
                    self.responseButton.imageView?.transform = self.responseButton.imageView!.transform.rotated(by: (.pi / 2.0) * -1.0)
                }
            }

            self.view.layoutIfNeeded()
        })
    }

    @IBAction private func requestButtonTouched(_ sender: UIButton) {
        requestIsOpen.toggle()
    }

    @IBAction private func responseButtonTouched(_ sender: UIButton) {
        responseIsOpen.toggle()
    }
}
