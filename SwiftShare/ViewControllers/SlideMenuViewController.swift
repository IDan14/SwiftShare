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

/// Base class for a sliding menu (left or right side hamburger menu).
open class SlideMenuViewController: UIViewController, SlideMenu {

    public enum SlideSide {
        case left
        case right
    }
    open var slideSide = SlideSide.left

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
        guard let sideMenu = sideMenuNC else { return }
        updateSideMenuSize()
        if slideMenuState == .animateOpen {
            slideMenuState = .dragOpen
            animateSideMenuSlide()
        } else if slideMenuState == .animateClose {
            slideMenuState = .dragClose
            animateSideMenuSlide()
        } else if slideMenuState == .opened {
            if (slideSide == .left && sideMenu.view.frame.origin.x != 0) {
                sideMenu.view.frame.origin.x = 0
            } else if (slideSide == .right && sideMenu.view.frame.origin.x != self.view.frame.width - sideMenu.view.frame.width) {
                sideMenu.view.frame.origin.x = self.view.frame.width - sideMenu.view.frame.width
            }
        } else if slideMenuState == .closed {
            if (slideSide == .left && sideMenu.view.frame.origin.x != -sideMenu.view.frame.width) {
                sideMenu.view.frame.origin.x = -sideMenu.view.frame.width
            } else if (slideSide == .right && sideMenu.view.frame.origin.x != self.view.frame.width) {
                sideMenu.view.frame.origin.x = self.view.frame.width
            }
        }
    }

    open func checkOrAddSideMenuViewController() {
        if sideMenuNC == nil, let sideMenu = try? createSideMenuNavigationController() {
            sideMenuNC = sideMenu
            closeSideMenu()
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

    private func updateSideMenuShadow() {
        if let sideMenu = sideMenuNC {
            if slideMenuState == .closed {
                sideMenu.view.layer.shadowOpacity = 0.0
            } else {
                sideMenu.view.layer.shadowOpacity = 0.5
            }
        }
    }

    open func animateSideMenuSlide() {
        checkOrAddSideMenuViewController()
        guard let sideMenu = sideMenuNC else { return }
        if slideMenuState.isAnimating() {
            return
        } else if slideMenuState == .dragOpen {
            if (slideSide == .left && sideMenu.view.frame.origin.x == 0)
                || (slideSide == .right && sideMenu.view.frame.origin.x == self.view.frame.width - sideMenu.view.frame.width) {
                slideMenuState = .opened
                return
            } else {
                slideMenuState = .animateOpen
            }
        } else if slideMenuState == .dragClose {
            if (slideSide == .left && sideMenu.view.frame.origin.x == -sideMenu.view.frame.width)
                || (slideSide == .right && sideMenu.view.frame.origin.x == self.view.frame.width) {
                slideMenuState = .closed
                updateSideMenuShadow()
                return
            } else {
                slideMenuState = .animateClose
            }
        } else if slideMenuState == .opened {
            slideMenuState = .animateClose
        } else if slideMenuState == .closed {
            slideMenuState = .animateOpen
        }
        updateSideMenuShadow()
        UIView.animate(withDuration: sideMenuSlideDuration, delay: 0, options: [.allowUserInteraction], animations: {
            if self.slideMenuState == .animateOpen {
                sideMenu.view.frame.origin.x = (self.slideSide == .left) ? 0 : self.view.frame.width - sideMenu.view.frame.width
            } else if self.slideMenuState == .animateClose {
                sideMenu.view.frame.origin.x = (self.slideSide == .left) ? -sideMenu.view.frame.width : self.view.frame.width
            }
        }) { (completed) in
            if self.slideMenuState == .animateOpen {
                self.slideMenuState = .opened
            } else if self.slideMenuState == .animateClose {
                self.slideMenuState = .closed
            }
            if completed {
                self.updateSideMenuShadow()
            }
        }
    }

    private func closeSideMenu() {
        self.slideMenuState = .closed
        if let sideMenu = sideMenuNC {
            updateSideMenuShadow()
            updateSideMenuSize()
            switch slideSide {
            case .left:
                sideMenu.view.frame.origin.x = -sideMenu.view.frame.width
            case .right:
                sideMenu.view.frame.origin.x = self.view.frame.width
            }

        }
    }

    @objc
    private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let horizontalVelocity = recognizer.velocity(in: self.view).x
        switch recognizer.state {
        case .began:
            checkOrAddSideMenuViewController()
            checkSideMenuTouched(recognizer.location(in: self.view))
            sideMenuNC?.view.layer.removeAllAnimations()
            if isTouchingSideMenu {
                if slideMenuState == .opened {
                    slideMenuState = .dragClose
                } else if slideMenuState == .closed {
                    slideMenuState = .dragOpen
                }
                updateSideMenuShadow()
            }
        case .ended, .cancelled:
            if isTouchingSideMenu {
                animateSideMenuSlide()
                isTouchingSideMenu = false
            }
        case .changed:
            guard let sideMenu = sideMenuNC, isTouchingSideMenu else {
                return
            }
            setSlideMenuDragState(horizontalVelocity)
            sideMenu.view.frame.origin.x += recognizer.translation(in: sideMenu.view).x
            switch slideSide {
            case .left:
                if sideMenu.view.frame.origin.x > 0 {
                    sideMenu.view.frame.origin.x = 0
                } else if sideMenu.view.frame.origin.x < -sideMenu.view.frame.width {
                    sideMenu.view.frame.origin.x = -sideMenu.view.frame.width
                }
            case .right:
                if sideMenu.view.frame.origin.x > self.view.frame.width {
                    sideMenu.view.frame.origin.x = self.view.frame.width
                } else if sideMenu.view.frame.origin.x < self.view.frame.width - sideMenu.view.frame.width {
                    sideMenu.view.frame.origin.x = self.view.frame.width - sideMenu.view.frame.width
                }
            }
            recognizer.setTranslation(CGPoint.zero, in: view)
        default:
            SwiftyBeaver.warning("other recognizer state")
        }
    }

    private func setSlideMenuDragState(_ velocity: CGFloat) {
        let newState: SlideState
        if velocity > 0 {
            newState = (slideSide == .left) ? .dragOpen : .dragClose
        } else if velocity < 0 {
            newState = (slideSide == .left) ? .dragClose : .dragOpen
        } else {
            return
        }
        if slideMenuState != newState {
            slideMenuState = newState
        }
    }

    private func checkSideMenuTouched(_ point: CGPoint) {
        if let sideMenu = sideMenuNC {
            switch slideSide {
            case .left:
                isTouchingSideMenu = (point.x - sideMenu.view.frame.maxX - sideMenuTouchEdge) < 0
            case .right:
                isTouchingSideMenu = (point.x - sideMenu.view.frame.minX + sideMenuTouchEdge) > 0
            }
//            SwiftyBeaver.info("pointX: \(point.x) | sideMenu frame: \(sideMenu.view.frame) | isTouchingSideMenu: \(isTouchingSideMenu)")
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
//        SwiftyBeaver.verbose("didSetSlideMenuState \(slideMenuState)")
        if let sideMenu = sideMenuNC, slideMenuState == .closed {
            if sideMenu.viewControllers.count > 1 {
                sideMenu.popToRootViewController(animated: false)
            }
        }
    }
}
