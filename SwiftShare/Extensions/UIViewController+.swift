//
//  UIViewController+.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit

public extension UIViewController {

    func displayAlert(message: String,
                      title: String? = nil,
                      completion: (() -> Swift.Void)? = nil,
                      clickHandler: (() -> Swift.Void)? = nil,
                      canReplacePreviousModal: Bool = true) {
        let titleString = NSLocalizedString(title ?? "Alert Title - Any error", comment: "")
        let messageString = NSLocalizedString(message, comment: "")
        self.displayAlert(localizedMessage: messageString, localizedTitle: titleString, completion: completion,
                          clickHandler: clickHandler, canReplacePreviousModal: canReplacePreviousModal)
    }

    func displayAlert(localizedMessage: String,
                      localizedTitle: String = NSLocalizedString("Alert Title - Any error", comment: ""),
                      completion: (() -> Swift.Void)? = nil,
                      clickHandler: (() -> Swift.Void)? = nil,
                      canReplacePreviousModal: Bool = true) {
        let alert = UIAlertController(title: localizedTitle, message: localizedMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default,
                                      handler: (clickHandler == nil) ? nil : { (_) in clickHandler?()}))

        if self.presentedViewController != nil {
            let allowDismiss = (presentedViewController as? SimpleBaseViewController)?.canBeDismissedByNextModal ?? true
            if canReplacePreviousModal && allowDismiss {
                self.dismiss(animated: true, completion: {
                    self.present(alert, animated: true, completion: completion)
                })
            }
        } else {
            self.present(alert, animated: true, completion: completion)
        }
    }
}
