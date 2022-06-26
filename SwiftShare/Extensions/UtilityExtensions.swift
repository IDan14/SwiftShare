//
//  UtilityExtensions.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit

infix operator ^^ : LogicalDisjunctionPrecedence
public func ^^ (left: Bool, right: Bool) -> Bool {
    return left != right
}

public extension String {
    static func hexStringFromData(_ data: Data) -> String {
        return data.reduce("") { $0 + String(format: "%02x", $1)}
    }
}

public extension CustomStringConvertible {
    var description: String {
        var description: String = "{\n"
        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children {
            if let propertyName = child.label, let propertyValue = unwrap1(child.value) {
                description += "\t\(propertyName): \(propertyValue)\n"
            }
        }
        description += "}"
        return description
    }
}

public extension CustomDebugStringConvertible {
    var debugDescription: String {
        var description: String = "{\n"
        let selfMirror = Mirror(reflecting: self)
        for child in selfMirror.children {
            if let propertyName = child.label {
                description += "\t\(propertyName): \(unwrap2(child.value))\n"
            }
        }
        description += "}"
        return description
    }
}

private func unwrap1<T>(_ any: T) -> Any? {
    let mirror = Mirror(reflecting: any)
    guard mirror.displayStyle == .optional else {
        return any
    }
    return mirror.children.first?.value
}

private func unwrap2<T>(_ any: T) -> Any {
    let mirror = Mirror(reflecting: any)
    guard mirror.displayStyle == .optional, let first = mirror.children.first else {
        return any
    }
    return first.value
}

public extension NSAttributedString {

    class func loadRichTextFormatDocument(url: URL) throws -> NSAttributedString {
        return try NSAttributedString(url: url, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf],
                                      documentAttributes: nil)
    }

    func setLink(keyText: String, linkUrl: URL, font: UIFont) -> NSAttributedString {
        if let keyRange = self.string.range(of: keyText) {
            let output = NSMutableAttributedString(attributedString: self)
            output.addAttributes([.link: linkUrl, .font: font], range: NSRange(keyRange, in: self.string))
            return output
        } else {
            return self
        }
    }
}

public extension NSMutableAttributedString {

    @discardableResult
    func append(text: String, font: UIFont? = nil, color: UIColor? = nil) -> NSMutableAttributedString {
        if let customFont = font {
            var attrs: [NSAttributedString.Key: Any] = [.font: customFont]
            if let customColor = color {
                attrs[.foregroundColor] = customColor
            }
            append(NSAttributedString(string: text, attributes: attrs))
        } else {
            append(NSAttributedString(string: text))
        }
        return self
    }
}
