//
//  UITextField+.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit

public extension UITextField {

    class func chainTextFields(_ fields: [UITextField], lastTargetAction: Selector? = nil) {
        guard let last = fields.last else {
            return
        }
        for index in 0 ..< fields.count - 1 {
            fields[index].returnKeyType = .next
            fields[index].addTarget(fields[index + 1], action: #selector(UIResponder.becomeFirstResponder), for: .editingDidEndOnExit)
        }
        if let action = lastTargetAction {
            last.addTarget(nil, action: action, for: .editingDidEndOnExit)
        } else {
            last.addTarget(last, action: #selector(UIResponder.resignFirstResponder), for: .editingDidEndOnExit)
        }
    }
}
