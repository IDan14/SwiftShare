//
//  SegueGoLeftToRight.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit

/// Segue with custom animation for presenting a view controller modally
/// - Note: Based on [https://www.appcoda.com/custom-segue-animations](https://www.appcoda.com/custom-segue-animations)
@available(iOSApplicationExtension, unavailable)
public class SegueGoLeftToRight: UIStoryboardSegue {
    override open func perform() {
        if let firstView = self.source.view, let secondView = self.destination.view {
            let screenWidth = UIScreen.main.bounds.size.width
            let screenHeight = UIScreen.main.bounds.size.height
            secondView.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
            let window = getKeyWindow()
            window?.insertSubview(secondView, aboveSubview: firstView)

            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                firstView.frame = firstView.frame.offsetBy(dx: -firstView.bounds.width / 2, dy: 0)
                secondView.frame = secondView.frame.offsetBy(dx: -secondView.bounds.width, dy: 0)
            }, completion: { _ in
                self.destination.modalPresentationStyle = .fullScreen
                self.source.present(self.destination, animated: false, completion: nil)
            })
        }
    }

    private func getKeyWindow() -> UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .filter { $0.isKeyWindow }.first
    }
}
