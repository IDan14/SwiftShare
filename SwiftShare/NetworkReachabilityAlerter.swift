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

    public init?(showOnStart: Bool) {
        guard let reachabilityManager = Alamofire.NetworkReachabilityManager() else {
            SwiftyBeaver.error("Network reachability manager initialization failed")
            return nil
        }
        networkReachabilityManager = reachabilityManager
        if !reachabilityManager.isReachable {
            if showOnStart {
                SwiftyBeaver.warning("Network status in not reachable (on start)")
                displayNotReachableAlert()
            }
        }

        reachabilityManager.startListening { [weak self] (status) in
            switch status {
            case .notReachable:
                SwiftyBeaver.warning("Network status in not reachable")
                self?.displayNotReachableAlert()
            case .reachable(let connectionType):
                SwiftyBeaver.info("Network status is reachable, connection type: \(connectionType)")
            case .unknown:
                SwiftyBeaver.warning("Network status in unknown")
            }
        }
    }

    public func isReachable() -> Bool {
        return networkReachabilityManager.isReachable
    }

    private func displayNotReachableAlert() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        rootViewController.displayAlert(localizedMessage: NSLocalizedString("Alert Message - Not reachable", comment: "Network status in not reachable"),
                                        localizedTitle: NSLocalizedString("Alert Title - Not reachable", comment: "No connection"))
    }
}
