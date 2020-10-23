//
//  UpdateOverlay.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit
import SwiftyBeaver

@available(iOSApplicationExtension, unavailable)
open class UpdateOverlay {

    public init() {}

    /// Display modal view controller with update message and options based on status.
    ///
    /// Override `buildOverlay` & `customizeOverlay` methods if you need to customize the UI.
    /// - Parameters:
    ///   - presenter: view controller acting as presenter
    ///   - status: update version information
    ///   - skipAction: if not `nil` adds a "Skip" button implementing specified action (when version status is marked as older)
    open func displayIfNecessary(presenter: UIViewController, status: VersionStatus, skipAction: (() -> Void)?) {
        let message: String
        let updateUrl: String?
        let allowCancel: Bool
        switch status {
        case .belowMinimum(message: let msg, updateUrl: let url, latestVersion: _):
            message = msg
            updateUrl = url
            allowCancel = false
        case .older(message: let msg, updateUrl: let url, latestVersion: _):
            message = msg
            updateUrl = url
            allowCancel = true
        case .skipped, .newer, .upToDate:
            SwiftyBeaver.info("Application up to date, newer or version marked as skipped")
            return
        }
        let overlay = buildOverlay(updateUrl: updateUrl, allowCancel: allowCancel, skipAction: skipAction)
        customizeOverlay(overlay)
        overlay.textView.text = message
        overlay.canBeDismissedByNextModal = false
        presenter.present(overlay, animated: true, completion: nil)
    }

    open func buildOverlay(updateUrl: String?, allowCancel: Bool, skipAction: (() -> Void)?) -> SimpleTextViewController {
        let viewController = SimpleTextViewController()
        viewController.addButton(title: NSLocalizedString("Update", comment: "Update button text")) {
            if let urlString = updateUrl,
                let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
        }
        if allowCancel {
            if let skipAction = skipAction {
                viewController.addButton(title: NSLocalizedString("Skip update", comment: "Skip button")) {
                    skipAction()
                    viewController.dismiss(animated: true, completion: nil)
                }
            }
            viewController.addButton(title: NSLocalizedString("No update now", comment: "Cancel button"))
        }
        return viewController
    }

    open func customizeOverlay(_ viewController: SimpleTextViewController) {
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.modalTransitionStyle = .crossDissolve
        viewController.isVerticallyCentered = true
        viewController.contentHeightRatio = 0.4
    }
}
