//
//  AppVersionChecker.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import Foundation

open class AppVersionChecker {

    public init() {}

    /// Utility method for loading VersionData object from a file URL.
    /// - Throws: AppDataError instances
    open func loadVersionData(_ fileURL: URL) throws -> VersionData {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(VersionData.self, from: data)
        } catch let error as DecodingError {
            logger.warning("JSON decoding failed: \(error)")
            throw AppDataError.jsonParsingError(reason: "Failed to decode version data")
        } catch {
            logger.warning("Data loading faled: \(error)")
            throw AppDataError.noData(reason: "Failed to load version data")
        }
    }

    /// Check installed app version.
    ///
    /// - Parameters:
    ///   - installedVersion: If nil installed version is obtained from bundle (Info.plist)
    ///   - skippedVersion: Update version marked as skipped. Ignored if it is below minimal version.
    ///   - languageCode: If nil value is obtained from current locale
    ///   - latestVersionData: object describing update information
    /// - Returns: Version status, including upgrade message and url when appropriate
    /// - Throws: AppDataError instances
    open func check(installedVersion: String? = nil,
                    skippedVersion: String? = nil,
                    languageCode: String? = nil,
                    latestVersionData: VersionData) throws -> VersionStatus {
        guard let installedVersion = installedVersion ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
            throw AppDataError.noData(reason: "Missing installed version")
        }
        let languageCode = languageCode ?? Locale.current.languageCode
        let minimal = latestVersionData.minimalVersion
        let latest = latestVersionData.latestVersion
        let messages = getUpdateMessages(latestVersionData.messages, languageCode: languageCode)

        if versionCompare(first: installedVersion, second: minimal) == .orderedAscending {
            return VersionStatus.belowMinimum(message: messages.forcedUpdate, updateUrl: latestVersionData.updateLink, latestVersion: latest)
        } else {
            switch versionCompare(first: installedVersion, second: latest) {
            case .orderedAscending:
                if skippedVersion == latest {
                    return VersionStatus.skipped
                } else {
                    return VersionStatus.older(message: messages.recommendedUpdate, updateUrl: latestVersionData.updateLink, latestVersion: latest)
                }
            case .orderedSame:
                return VersionStatus.upToDate
            case .orderedDescending:
                return VersionStatus.newer
            }
        }
    }

    /// Method used internally to compare app versions.
    open func versionCompare(first: String, second: String) -> ComparisonResult {
        return first.compare(second, options: .numeric)
    }

    /// Provides update messages based on Localizable.strings
    ///
    /// Used when VersionData does not contain (language specific) update messages.
    /// Localizable.strings should include for example:
    /// - "Forced update" = "A new version of %@ is available. Please update the app now.";
    /// - "Recommended update" = "A new version of %@ is available.";
    open func getDefaultUpdateMessages() -> (forcedUpdate: String, recommendedUpdate: String) {
        guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String else {
            return ("Error", "Error")
        }
        let forcedUpdate = String(format: NSLocalizedString("Forced update", comment: ""), appName)
        let recommededUpdate = String(format: NSLocalizedString("Recommended update", comment: ""), appName)
        return (forcedUpdate, recommededUpdate)
    }

    private func getUpdateMessages(_ messages: [VersionData.UpdateMessage]?, languageCode: String?) -> (forcedUpdate: String, recommendedUpdate: String) {
        if let lang = languageCode,
            let updateMessage = messages?.first(where: { $0.language == lang }) {
            return (updateMessage.forcedUpdate, updateMessage.recommendedUpdate)
        }
        return getDefaultUpdateMessages()
    }
}
