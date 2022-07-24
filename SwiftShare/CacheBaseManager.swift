//
//  CacheBaseManager.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import Foundation

open class CacheBaseManager {

    public init() {}

    /// Load last instance saved using the same storage instance.
    /// - Parameters:
    ///   - storage: Storage instance used to manage object.
    ///   - expirationDate: (optional, default `nil`) only return object if data has been saved after this expiration date.
    ///   - deleteIfExpired: (optional, default `true`) delete data file if it has expired. No effect if `expirationDate` is not set.
    /// - Returns: Object from cache or `nil` if no data exists or is expired or there is an error loading data.
    open func load<T: Codable>(_ storage: Storage<T>, expirationDate: Date? = nil, deleteIfExpired: Bool = true) -> T? {
        do {
            if let item = try storage.load() {
                return item
            } else {
                return nil
            }
        } catch {
            logger.error(AppDataError.cachingError(reason: "Load \(T.self) failed: \(error)"))
            return nil
        }
    }

    /// Save object to cache, replacing previous value set using same storage instance.
    /// - Parameters:
    ///   - value: Object to be saved.
    ///   - storage: Storage instance used to manage object.
    open func save<T: Codable>(_ storage: Storage<T>, value: T) {
        do {
            try storage.save(value)
        } catch {
            logger.error(AppDataError.cachingError(reason: "Save \(T.self) failed: \(error)"))
        }
    }

    /// Delete object saved using the same storage instance.
    /// - Parameter storage: Storage instance used to manage object.
    open func delete<T: Codable>(_ storage: Storage<T>) {
        do {
            try storage.delete()
        } catch {
            logger.error(AppDataError.cachingError(reason: "Clear cache file failed: \(error)"))
        }
    }
}
