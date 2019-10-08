//
//  VersionStatus.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

public enum VersionStatus: Equatable {
    case belowMinimum(message: String, updateUrl: String?, latestVersion: String)   // force update
    case older(message: String, updateUrl: String?, latestVersion: String)          // recommend update
    case skipped        // version reported by server marked as skipped, no message
    case upToDate       // same as version reported by server, no message
    case newer          // newer than version reported by server, no message

    public func isBlocked() -> Bool {
        switch self {
        case .belowMinimum:
            return true
        default:
            return false
        }
    }
}
