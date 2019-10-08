//
//  NetworkReachabilityAlerter.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyBeaver

public class NetworkReachabilityAlerter {

    private let networkReachabilityManager: Alamofire.NetworkReachabilityManager
    private var alertPresenter: UIViewController?

    public init?(alertPresenter: UIViewController?) {
        if let reachabilityManager = Alamofire.NetworkReachabilityManager() {
            self.networkReachabilityManager = reachabilityManager
            self.alertPresenter = alertPresenter

            if !reachabilityManager.isReachable {
                SwiftyBeaver.warning("Network status in not reachable (on start)")
                if let presenter = alertPresenter {
                    self.displayNotReachableAlert(presenter)
                }
            }

            reachabilityManager.listener = { (status) in
                switch status {
                case .notReachable:
                    SwiftyBeaver.warning("Network status in not reachable")
                    if let presenter = alertPresenter {
                        self.displayNotReachableAlert(presenter)
                    }
                case .reachable(let connectionType):
                    SwiftyBeaver.info("Network status is reachable, connection type: \(connectionType)")
                case .unknown:
                    SwiftyBeaver.warning("Network status in unknown")
                }
            }
            reachabilityManager.startListening()
        } else {
            SwiftyBeaver.error("Network reachability manager initialization failed")
            return nil
        }
    }

    public func setAlertPresenter(alertPresenter: UIViewController?) {
        self.alertPresenter = alertPresenter
    }

    public func isReachable() -> Bool {
        return self.networkReachabilityManager.isReachable
    }

    private func displayNotReachableAlert(_ presenter: UIViewController) {
        presenter.displayAlert(localizedMessage: NSLocalizedString("Alert Message - Not reachable", comment: "Network status in not reachable"),
                               localizedTitle: NSLocalizedString("Alert Title - Not reachable", comment: "No connection"))
    }
}
