//
//  UIImage+.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit

public extension UIImage {

    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let cgImage = image?.cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }

    /// Resize image.
    /// - Parameters:
    ///   - bounds: The size (measured in points) of the new bitmap.
    ///   - aspectFit: A Boolean flag indicating whether to use aspectFit or aspectFill rule.
    ///   - opaque: A Boolean flag indicating whether the bitmap is opaque.
    ///   - newScale: The scale factor to apply to the bitmap. If you specify a value of 0.0, the scale factor is set to the scale factor of the device’s main screen.
    /// - Returns: New resized image
    func resized(to bounds: CGSize, aspectFit: Bool = true, opaque: Bool = true, newScale: CGFloat = 0) -> UIImage {
        let hRatio = bounds.width / size.width
        let vRatio = bounds.height / size.height
        let ratio = aspectFit ? min(hRatio, vRatio) : max(hRatio, vRatio)
        let newSize = CGSize(width: round(size.width * ratio), height: round(size.height * ratio))
        UIGraphicsBeginImageContextWithOptions(newSize, opaque, newScale)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
