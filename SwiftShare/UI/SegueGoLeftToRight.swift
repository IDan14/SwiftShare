//
//  SegueGoLeftToRight.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit

// based on: https://www.appcoda.com/custom-segue-animations/
@available(iOSApplicationExtension, unavailable)
public class SegueGoLeftToRight: UIStoryboardSegue {
    override open func perform() {
        if let firstView = self.source.view, let secondView = self.destination.view {
            let screenWidth = UIScreen.main.bounds.size.width
            let screenHeight = UIScreen.main.bounds.size.height
            secondView.frame = CGRect(x: screenWidth, y: 0, width: screenWidth, height: screenHeight)
            let window = UIApplication.shared.keyWindow
            window?.insertSubview(secondView, aboveSubview: firstView)

            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: {
                firstView.frame = firstView.frame.offsetBy(dx: -firstView.bounds.width / 2, dy: 0)
                secondView.frame = secondView.frame.offsetBy(dx: -secondView.bounds.width, dy: 0)
            }, completion: { _ in self.source.present(self.destination, animated: false, completion: nil) })
        }
    }
}
