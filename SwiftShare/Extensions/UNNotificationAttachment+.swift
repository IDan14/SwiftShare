//
//  UNNotificationAttachment+.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import UserNotifications
import SwiftyBeaver

public extension UNNotificationAttachment {

    static func createAttachment(fileIdentifier: String, data: Data) -> UNNotificationAttachment? {
        let subFolderName = ProcessInfo.processInfo.globallyUniqueString
        let subFolderURL = FileManager.default.temporaryDirectory.appendingPathComponent(subFolderName, isDirectory: true)
        do {
            try FileManager.default.createDirectory(at: subFolderURL, withIntermediateDirectories: true, attributes: nil)
            let fileURL = subFolderURL.appendingPathComponent(fileIdentifier)
            try data.write(to: fileURL)
            return try UNNotificationAttachment(identifier: fileIdentifier, url: fileURL, options: nil)
        } catch {
            SwiftyBeaver.error(error, "Failed to create notification attachment")
        }
        return nil
    }
}
