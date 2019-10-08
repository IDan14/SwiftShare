//
//  SimpleBaseViewController.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit

open class SimpleBaseViewController: UIViewController {

    public typealias ButtonAction = (() -> Void)

    public private (set) var contentView = UIView()
    public private (set) var separatorView = UIView()
    public private (set) var buttonsView = UIStackView()
    public private (set) var buttons = [UIButton]()
    private var buttonActions = [ButtonAction]()

    open var contentWidthRatio = CGFloat(0.8)
    open var contentHeightRatio = CGFloat(0.8)
    open var canBeDismissedByNextModal = true

    override open func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        if buttons.isEmpty {
            addButton(title: NSLocalizedString("Close", comment: "Close button"))
        }
        addContentView()
        addSeparatorView()
        addButtonsView()
        addButtons()
    }

    // MARK: -

    open func addButton(title: String, titleColor: UIColor = .black, action: ButtonAction? = nil) {
        let button = UIButton()
        setupButton(button, title: title, titleColor: titleColor)
        buttons.append(button)
        buttonActions.append(action ?? { self.dismiss(animated: true, completion: nil) })
    }

    open func addMainView(_ newView: UIView, parentView: UIView) {
        parentView.addSubview(newView)
        newView.translatesAutoresizingMaskIntoConstraints = false
        newView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        newView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        newView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        newView.bottomAnchor.constraint(equalTo: separatorView.topAnchor).isActive = true
    }

    open func addSeparatorView() {
        addBottomView(separatorView, height: 61)
    }

    open func addButtonsView() {
        buttonsView.axis = .horizontal
        buttonsView.distribution = .fillEqually
        buttonsView.spacing = 1
        addBottomView(buttonsView, height: 60)
    }

    // MARK: -

    private func addButtons() {
        for button in buttons {
            button.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
            buttonsView.addArrangedSubview(button)
        }
    }

    private func setupButton(_ button: UIButton, title: String, titleColor: UIColor = .black) {
        button.setTitle(title, for: .normal)
        button.setTitleColor(titleColor, for: .normal)
        button.backgroundColor = .white
    }

    private func addContentView() {
        view.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: contentWidthRatio),
            contentView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: contentHeightRatio)
        ])
        contentView.backgroundColor = UIColor.white
    }

    private func addBottomView(_ theView: UIView, height: CGFloat) {
        contentView.addSubview(theView)
        theView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            theView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            theView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            theView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            theView.heightAnchor.constraint(equalToConstant: height)
        ])
    }

    @objc
    private func buttonClick(_ sender: AnyObject?) {
        for item in buttons.enumerated() where sender === item.element {
            buttonActions[item.offset]()
            break
        }
    }
}
