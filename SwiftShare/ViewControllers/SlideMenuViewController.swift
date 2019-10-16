//
//  SlideMenuViewController.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit
import SwiftyBeaver

public protocol SlideMenu {
    func createMainViewController() throws -> UIViewController
    func createSideMenuNavigationController() throws -> UINavigationController
    func didSetSlideMenuState()
}

/// Base class for a sliding menu (left-side hamburger menu).
open class SlideMenuViewController: UIViewController, SlideMenu {

    public enum SlideState {
        case closed
        case opened
        case dragOpen
        case dragClose
        case animateOpen
        case animateClose

        func isAnimating() -> Bool {
            return (self == .animateOpen || self == .animateClose)
        }

        mutating func nextState() {
            switch self {
            case .closed, .dragOpen:
                self = .animateOpen
            case .opened, .dragClose:
                self = .animateClose
            case .animateOpen:
                self = .opened
            case .animateClose:
                self = .closed
            }
        }
    }
    open var slideMenuState = SlideState.closed {
        didSet {
            didSetSlideMenuState()
        }
    }

    public private (set) var mainVC: UIViewController?
    public private (set) var sideMenuNC: UINavigationController?

    open var sideMenuOpenScreenWidthRatio = CGFloat(0.8)
    open var sideMenuTouchEdge = CGFloat(60)
    open var sideMenuSlideDuration = 0.5
    private var isTouchingSideMenu = false

    override open func viewDidLoad() {
        super.viewDidLoad()
        addMainViewController()
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }

    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateSideMenuSize()
    }

    open func checkOrAddSideMenuViewController() {
        if sideMenuNC == nil, let sideMenu = try? createSideMenuNavigationController() {
            sideMenuNC = sideMenu
            closeSideMenu(updateSize: true)
            self.view.addSubview(sideMenu.view)
            addChild(sideMenu)
            sideMenu.didMove(toParent: self)
        }
    }

    private func addMainViewController() {
        if let main = try? createMainViewController() {
            view.addSubview(main.view)
            addChild(main)
            main.didMove(toParent: self)
            mainVC = main
        }
    }

    private func updateSideMenuSize() {
        if let sideMenu = sideMenuNC {
            sideMenu.view.frame.size = CGSize(width: self.view.frame.width * sideMenuOpenScreenWidthRatio, height: self.view.frame.height)
        }
    }

    private func updateSideMenuShadow(show: Bool) {
        if self.slideMenuState == .closed, let sideMenu = sideMenuNC {
            sideMenu.view.layer.shadowOpacity = show ? 0.5 : 0.0
        }
    }

    open func animateSideMenuSlide() {
        checkOrAddSideMenuViewController()
        guard let sideMenu = sideMenuNC else { return }
        if self.slideMenuState.isAnimating() {
            return
        } else if self.slideMenuState == .dragOpen && sideMenu.view.frame.origin.x == 0 {
            self.slideMenuState = .opened
            return
        } else if self.slideMenuState == .dragClose && sideMenu.view.frame.origin.x == -sideMenu.view.frame.width {
            self.slideMenuState = .closed
            return
        }
        updateSideMenuShadow(show: true)
        self.slideMenuState.nextState()
        UIView.animate(withDuration: sideMenuSlideDuration, animations: {
            if self.slideMenuState == .animateOpen {
                sideMenu.view.frame.origin.x = 0
            } else if self.slideMenuState == .animateClose {
                sideMenu.view.frame.origin.x = -sideMenu.view.frame.width
            }
        }) { _ in
            self.slideMenuState.nextState()
            self.updateSideMenuShadow(show: false)
        }
    }

    private func closeSideMenu(updateSize: Bool = false) {
        self.slideMenuState = .closed
        if let sideMenu = sideMenuNC {
            updateSideMenuShadow(show: false)
            if updateSize {
                self.updateSideMenuSize()
            }
            sideMenu.view.frame.origin.x = -sideMenu.view.frame.width
        }
    }

    @objc
    private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let horizontalVelocity = recognizer.velocity(in: self.view).x
        switch recognizer.state {
        case .began:
            checkOrAddSideMenuViewController()
            checkSideMenuTouched(recognizer.location(in: self.view))
            updateSideMenuShadow(show: isTouchingSideMenu)
        case .ended, .cancelled:
            if isTouchingSideMenu || slideMenuState != .closed {
                animateSideMenuSlide()
            }
            self.isTouchingSideMenu = false
        case .changed:
            guard let sideMenu = sideMenuNC, isTouchingSideMenu else {
                return
            }
            setSlideMenuDragState(horizontalVelocity)
            sideMenu.view.frame.origin.x += recognizer.translation(in: sideMenu.view).x
            if sideMenu.view.frame.origin.x > 0 {
                sideMenu.view.frame.origin.x = 0
            } else if sideMenu.view.frame.origin.x < -sideMenu.view.frame.width {
                sideMenu.view.frame.origin.x = -sideMenu.view.frame.width
            }
            recognizer.setTranslation(CGPoint.zero, in: view)
        default:
            SwiftyBeaver.warning("other recognizer state")
        }
    }

    private func setSlideMenuDragState(_ velocity: CGFloat) {
        if velocity > 0 {
            self.slideMenuState = .dragOpen
        } else if velocity < 0 {
            self.slideMenuState = .dragClose
        }
    }

    private func checkSideMenuTouched(_ point: CGPoint) {
        if let sideMenu = sideMenuNC {
            let rightSideEdge = sideMenu.view.frame.maxX
            isTouchingSideMenu = ((point.x - rightSideEdge - sideMenuTouchEdge) < 0)
            //            logger.info("rightSideEdge: \(rightSideEdge) - x:\(point.x) - isTouchingSideMenu: \(isTouchingSideMenu)")
        }
    }

    // MARK: - SlideMenu

    open func createMainViewController() throws -> UIViewController {
        throw AppDataError.configurationError(reason: "Method must be overriden")
    }

    open func createSideMenuNavigationController() throws -> UINavigationController {
        throw AppDataError.configurationError(reason: "Method must be overriden")
    }

    open func didSetSlideMenuState() {
        if let sideMenu = sideMenuNC, slideMenuState == .closed {
            if sideMenu.viewControllers.count > 1 {
                sideMenu.popToRootViewController(animated: false)
            }
        }
    }
}
