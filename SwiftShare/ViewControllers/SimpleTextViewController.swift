//
//  SimpleTextViewController.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit

open class SimpleTextViewController: SimpleBaseViewController {

    public private (set) var textView = UITextView()
    open var isEditable = false
    public var isVerticallyCentered = false {
        didSet {
            if isVerticallyCentered {
                textView = VerticallyCenteredTextView()
            } else {
                textView = UITextView()
            }
        }
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        addMainView(textView, parentView: contentView)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        textView.isEditable = isEditable
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.flashScrollIndicators()
    }
}
