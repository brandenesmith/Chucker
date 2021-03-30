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
            updateViewForStateChange()
        }
    }

    private var responseIsOpen: Bool = true {
        didSet {
            updateViewForStateChange()
        }
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

    private func updateViewForStateChange() {
        UIView.animate(withDuration: 0.25, animations: {
            // CATransform3D.MakeRotation((float)(Math.PI / 180 * 45), 0.0001f, 0.0001f, 1);
            self.requestButton.imageView?.layer.transform = CATransform3DMakeRotation(
                (self.requestIsOpen) ? CGFloat(Double.pi / 2.0) : CGFloat(-(Double.pi / 2.0)),
                0,
                0,
                0
            )
            self.responseButton.imageView?.layer.transform = CATransform3DMakeRotation(
                (self.requestIsOpen) ? CGFloat(Double.pi / 2.0) : CGFloat(-(Double.pi / 2.0)),
                0,
                0,
                0
            )
        })
    }

    @IBAction private func requestButtonTouched(_ sender: UIButton) {
        requestIsOpen.toggle()
    }

    @IBAction private func responseButtonTouched(_ sender: UIButton) {
        responseIsOpen.toggle()
    }
}
