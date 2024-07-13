//
//  NetworkBaseManager.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import Foundation
import Alamofire

open class NetworkBaseManager {

    /// Error handler applied to all encountered errors.
    /// Closure expression returns true if error has been handled and no further handling is required.
    public var baseErrorHandler: ((_ error: Error) -> Bool)?

    public init() {}

    public static func verboseLog<T>(request: DataRequest, response: DataResponse<T, AFError>) {
        logger.verbose("REQUEST: \(request.description)")
        if let data = request.request?.httpBody {
            logger.verbose("REQUEST BODY: \(String(data: data, encoding: .utf8) ?? "")")
        }
        logger.verbose("RESPONSE: \(response.debugDescription)")
        if let data = response.data {
            logger.verbose("RESPONSE BODY: \(String(data: data, encoding: .utf8) ?? "")")
        }
    }

    public static func debugLog(request: Request, error: Error? = nil) {
        let requestType = request.request?.httpMethod ?? "Unknown HTTP Method"
        let requestPath = request.request?.url?.relativeString ?? "Unknown URL"
        if let error = error {
            logger.debug("\(requestType) /\(requestPath) call failed: \(error)")
        } else {
            logger.debug("\(requestType) /\(requestPath) call completed")
        }
    }

    func handleError(_ error: Error, for request: Request) -> AppDataError {
        Self.debugLog(request: request, error: error)
        let appDataError: AppDataError
        if let error = error as? AppDataError {
            appDataError = error
        } else {
            let appErrorCode: Int
            if let statusCode = request.response?.statusCode {
                appErrorCode = statusCode
            } else {
                let nsError = error as NSError
                appErrorCode = (nsError.domain == NSURLErrorDomain) ? nsError.code : 0
            }
            appDataError = AppDataError.networkError(reason: error.localizedDescription, code: appErrorCode, url: request.request?.url)
        }
        let handled = baseErrorHandler?(appDataError) ?? false
        return handled ? AppDataError.handledError : appDataError
    }
}
