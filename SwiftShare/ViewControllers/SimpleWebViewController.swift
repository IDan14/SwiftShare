//
//  SimpleWebViewController.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import WebKit

@available(iOSApplicationExtension, unavailable)
open class SimpleWebViewController: SimpleBaseViewController, WKNavigationDelegate {

    public private (set) var webView = WKWebView()
    open var webURL: URL?

    override open func viewDidLoad() {
        super.viewDidLoad()
        addMainView(webView, parentView: contentView)
        webView.navigationDelegate = self
        if let url = webURL {
            webView.load(URLRequest(url: url))
        }
    }

    open func webView(_ webView: WKWebView,
                      decidePolicyFor navigationAction: WKNavigationAction,
                      decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == WKNavigationType.linkActivated,
            let requestURL = navigationAction.request.url {
            decisionHandler(WKNavigationActionPolicy.cancel)
            UIApplication.shared.open(requestURL)
        } else {
            decisionHandler(WKNavigationActionPolicy.allow)
        }
    }
}
