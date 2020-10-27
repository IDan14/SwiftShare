//
//  HUDView.swift
//  Learn19
//
//  Created by Dan ILCA on 26/10/2020.
//  Copyright © 2020 Dan Ilca. All rights reserved.
//

import UIKit

open class HUDView: UIView {

    open var image: UIImage?
    open var imageResize: CGSize?
    open var text: String?
    open var textColor: UIColor = .white
    open var textFont: UIFont = .systemFont(ofSize: UIFont.labelFontSize)
    open var hudColor = UIColor(white: 0.3, alpha: 0.8)
    open var horizontalPadding = CGFloat(20)
    open var verticalPadding = CGFloat(20)
    open var animationDuration = 0.3

    private var parentView: UIView?

    open class func createHUD(text: String? = nil, image: UIImage? = nil, inView: UIView) -> HUDView {
        let hudView = HUDView(frame: inView.bounds)
        hudView.text = text
        hudView.image = image
        hudView.isOpaque = false
        hudView.isUserInteractionEnabled = true
        hudView.parentView = inView
        return hudView
    }

    open func show(animated: Bool = true) {
        parentView?.addSubview(self)
        if animated {
            alpha = 0
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            UIView.animate(withDuration: animationDuration) {
                self.alpha = 1
                self.transform = .identity
            }
        }
    }

    open func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        if animated {
            UIView.animate(withDuration: animationDuration) {
                self.alpha = 0
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            } completion: { _ in
                self.removeFromSuperview()
                completion?()
            }
        } else {
            removeFromSuperview()
            completion?()
        }
    }

    open override func draw(_ rect: CGRect) {
        var imageSize: CGSize = .zero
        var textSize: CGSize = .zero
        // Calculate drawing sizes
        if let image = image {
            imageSize = imageResize ?? image.size
        }
        var textAttr: [NSAttributedString.Key: Any] = [:]
        var nsText: NSString?
        if let text = text {
            textAttr = [
                NSAttributedString.Key.font: textFont,
                NSAttributedString.Key.foregroundColor: textColor
            ]
            nsText = NSString(string: text)
            textSize = nsText!.size(withAttributes: textAttr)
        }
        let boxWidth = max(textSize.width + 2 * horizontalPadding, imageSize.width + 2 * horizontalPadding)
        let boxHeight = textSize.height + imageSize.height + (imageSize.height == 0 ? 2 : 3) * verticalPadding
        let box = CGRect(x: round((bounds.width - boxWidth) / 2), y: round((bounds.height - boxHeight) / 2), width: round(boxWidth), height: round(boxHeight))
        // Draw box
        let boxPath = UIBezierPath(roundedRect: box, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10))
        hudColor.setFill()
        boxPath.fill()
        // Draw image
        if let image = image {
            let imagePoint = CGPoint(x: round(center.x - imageSize.width / 2), y: box.minY + verticalPadding)
            image.draw(in: CGRect(origin: imagePoint, size: imageSize))
        }
        // Draw text
        if let nsText = nsText {
            let textPoint = CGPoint(x: round(center.x - textSize.width / 2), y: round(box.maxY - verticalPadding - textSize.height))
            nsText.draw(at: textPoint, withAttributes: textAttr)
        }
    }
}
