//
//  UIContentSizeCategory+.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UIKit

public extension UIContentSizeCategory {

    var numericValue: Int {
        switch self {
        case .extraSmall:
            return -3
        case .small:
            return -2
        case .medium:
            return -1
        case .large:
            return 0
        case .extraLarge:
            return +1
        case .extraExtraLarge:
            return +2
        case .extraExtraExtraLarge:
            return +3
        case .accessibilityMedium:
            return +4
        case .accessibilityLarge:
            return +5
        case .accessibilityExtraLarge:
            return +6
        case .accessibilityExtraExtraLarge:
            return +7
        case .accessibilityExtraExtraExtraLarge:
            return +8
        default:
            return 0
        }
    }
}
