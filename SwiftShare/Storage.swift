//
//  Storage.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import Foundation

/// Class for saving and loading a `Codable` object to / from a file.
open class Storage<T> where T: Codable {

    private let fileURL: URL

    /// Initialize file URL used for storage.
    /// - Parameter folderName: folder name (inside caches directory) to be used for storage
    /// - Parameter filename: file name to be used for storage
    public convenience init(folderName: String, filename: String) throws {
        if let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let folderURL = URL(fileURLWithPath: path).appendingPathComponent(folderName)
            try self.init(folderURL: folderURL, filename: filename)
        } else {
            throw AppDataError.cachingError(reason: "Cannot create folder URL")
        }
    }

    /// Initialize file URL used for storage.
    /// - Parameters:
    ///   - folderURL: folder to be used for storage
    ///   - filename: file name to be used for storage
    public init(folderURL: URL, filename: String) throws {
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        fileURL = folderURL.appendingPathComponent(filename)
    }

    /// Save object to file.
    /// - Parameter value: `Codable` object to be saved
    /// - Throws: An error in the Cocoa domain, if there is an error saving object.
    open func save(_ value: T) throws {
        let data = try JSONEncoder().encode(value)
        try data.write(to: fileURL, options: .atomic)
    }

    /// Load object from file.
    /// - Parameter expirationDate: (optional, default `nil`) only return object if data has been saved after this expiration date
    /// - Parameter deleteIfExpired: (optional, default `true`) delete data file if it has expired. No effect if `expirationDate` is not set.
    /// - Returns: `Codable` object or `nil` if stored data file does not exist or is expired (and `expiredDate` parameter has been set)
    open func load(expirationDate: Date? = nil, deleteIfExpired: Bool = true) throws -> T? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }
        if let expirationDate = expirationDate {
            if let lastModifiedDate = try getLastModificationDate() {
                if lastModifiedDate <= expirationDate {
                    //                    logger.verbose("Expired data, last modified date: \(lastModifiedDate), expirationDate: \(expirationDate)")
                    if deleteIfExpired {
                        try delete()
                    }
                } else {
                    return try load()
                }
            } else {
                throw AppDataError.cachingError(reason: "Could not get cache file last modification date")
            }
        } else {
            return try load()
        }
        return nil
    }

    /// Delete data file.
    open func delete() throws {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return
        }
        try FileManager.default.removeItem(at: self.fileURL)
    }

    private func load() throws -> T? {
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func getLastModificationDate() throws -> Date? {
        let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
        return attributes[FileAttributeKey.modificationDate] as? Date
    }

}
