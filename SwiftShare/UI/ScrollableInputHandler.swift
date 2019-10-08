//
//  ScrollableInputHandler.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit

/// Helper class (for a view or view controller) for automatically scrolling text fields above on-screen keyboard.
open class ScrollableInputHandler: NSObject, UITextFieldDelegate {

    open var scrollPadding = CGFloat(10)

    private var scrollView: UIScrollView
    private var activeTextField: UITextField?
    private var scrollPreviousOffset: CGPoint?
    private var keyboardHeight: CGFloat = 0

    public init(scrollView: UIScrollView, tapViewToDismiss: UIView?) {
        self.scrollView = scrollView
        super.init()
        setup(tapViewToDismiss: tapViewToDismiss)
    }

    private func setup(tapViewToDismiss: UIView?) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
        if let tapView = tapViewToDismiss {
            tapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resignActiveTextField)))
        }
    }

    @objc
    open func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let textField = activeTextField {
            keyboardHeight = keyboardSize.height
            scrollTo(textField: textField)
        }
    }

    @objc
    open func keyboardWillHide(notification: NSNotification) {
        scrollView.setContentOffset(scrollPreviousOffset ?? .zero, animated: true)
        keyboardHeight = 0
    }

    @objc
    open func resignActiveTextField() {
        activeTextField?.resignFirstResponder()
        activeTextField = nil
    }

    private func scrollTo(textField: UITextField) {
        guard let textFieldSuperview = textField.superview else {
            return
        }
        let activeTextFieldBottom = textFieldSuperview.convert(textField.frame.origin, to: scrollView).y + textField.frame.size.height
        let distance = scrollView.bounds.size.height - keyboardHeight - activeTextFieldBottom - scrollPadding
        if distance < 0 {
            scrollView.setContentOffset(CGPoint(x: 0, y: -distance), animated: true)
        }
    }

    // MARK: - UITextFieldDelegate

    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeTextField = textField
        if keyboardHeight > 0 {
            scrollTo(textField: textField)
        }
        return true
    }
}
