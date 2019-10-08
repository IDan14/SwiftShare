//
//  HTTPStatusCodes.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import Foundation

public enum HTTPStatusCodes: Int {
    // 2xx Success
    case ok = 200
    case created = 201
    case noContent = 204
    // 4xx Client errors
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case methodNotAllowed = 405
    case notAcceptable = 406
    case requestTimeout = 408
    case conflict = 409
    case loginTimeout = 440
    // 5xx Server errors
    case internalServerError = 500
    case notImplemented = 501
    case badGateway = 502
    case serviceUnavailable = 503
}
