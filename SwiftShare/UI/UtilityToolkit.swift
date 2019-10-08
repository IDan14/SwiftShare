//
//  UtilityToolkit.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit
import WebKit

public class UtilityToolkit {

    /// Method to initialize a `WebKit` web view from code instead of IB (needed for versions below iOS 11 due to a platform implementation bug).
    /// Should be called from (`UIViewController`) `loadView()` method.
    /// - Parameter webContainterView: web view is added as a subview to this container view
    /// - Returns: new web view having constraints set to fill the container view
    public class func initWebView(webContainterView: UIView) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webContainterView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webContainterView.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal,
                                                           toItem: webContainterView, attribute: .top, multiplier: 1, constant: 0))
        webContainterView.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal,
                                                           toItem: webContainterView, attribute: .bottom, multiplier: 1, constant: 0))
        webContainterView.addConstraint(NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal,
                                                           toItem: webContainterView, attribute: .leading, multiplier: 1, constant: 0))
        webContainterView.addConstraint(NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal,
                                                           toItem: webContainterView, attribute: .trailing, multiplier: 1, constant: 0))
        return webView
    }

    public class func listAvailableFonts() {
        for fontFamily in UIFont.familyNames {
            print("Font family name: \(fontFamily)")
            let fontNames = UIFont.fontNames(forFamilyName: fontFamily)
            for font in fontNames {
                print("     Font name: \(font)")
            }
        }
    }
}
