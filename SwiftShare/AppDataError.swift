//
//  AppDataError.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import Foundation

public enum AppDataError: Error {
    case noData(reason: String)
    case networkError(reason: String, code: Int, url: URL?)
    case jsonParsingError(reason: String)
    case missingToken(reason: String)
    case cachingError(reason: String)
    case unsupportedOperation(reason: String)
    case configurationError(reason: String)
    case handledError
    case unknownError(reason: String)

    public var reason: String {
        switch self {
        case .noData(let msg):
            return msg
        case .networkError(let msg, _, _):
            return msg
        case .jsonParsingError(let msg):
            return msg
        case .missingToken(let msg):
            return msg
        case .cachingError(let msg):
            return msg
        case .unsupportedOperation(let msg):
            return msg
        case .configurationError(let msg):
            return msg
        case .handledError:
            return "Error has been handled by the app"
        case .unknownError(let msg):
            return msg
        }
    }

    public var shortDescription: String {
        switch self {
        case .noData:
            return "noData"
        case .networkError(_, let code, _):
            return "networkError.\(code)"
        case .jsonParsingError:
            return "jsonParsingError"
        case .missingToken:
            return "missingToken"
        case .cachingError:
            return "cachingError"
        case .unsupportedOperation:
            return "unsupportedOperation"
        case .configurationError:
            return "configurationError"
        case .handledError:
            return "handledError"
        case .unknownError:
            return "unknownError"
        }
    }

    public var code: Int? {
        switch self {
        case .networkError(_, let code, _):
            return code
        default:
            return nil
        }
    }
}
