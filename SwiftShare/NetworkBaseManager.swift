//
//  NetworkBaseManager.swift
//  SwiftShare
//
//  Created by Dan ILCA on 08/10/2019.
//  Copyright © 2019 Dan Ilca. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift
import SwiftyBeaver

open class NetworkBaseManager {

    public let jsonDecoder: JSONDecoder

    /// Error handler applied to all encountered errors.
    /// Closure expression returns true if error has been handled and no further handling is required.
    public var baseErrorHandler: ((_ error: Error) -> Bool)?

    public init() {
        self.jsonDecoder = JSONDecoder()
    }

    open func call(_ request: DataRequest, queue: DispatchQueue? = nil) -> Completable {
        return Completable.create(subscribe: { (event) -> Disposable in
            request.validate().responseData(queue: queue, completionHandler: { [weak self] (response) in
                guard let self = self else { return }
                NetworkBaseManager.verboseLog(request: request, response: response)
                switch response.result {
                case .success:
                    NetworkBaseManager.debugLog(request: request)
                    event(.completed)
                case .failure(let error):
                    if let appDataError = self.handleError(error, request: request, httpUrlResponse: response.response) {
                        event(.error(appDataError))
                    }
                }
            })
            return Disposables.create {
                request.cancel()
            }
        })
    }

    open func call<T>(_ request: DataRequest, type: T.Type, queue: DispatchQueue? = nil) -> Single<T> where T: Decodable {
        return Single.create(subscribe: { (event) -> Disposable in
            request.validate().responseData(queue: queue, completionHandler: { [weak self] (response) in
                guard let self = self else { return }
                NetworkBaseManager.verboseLog(request: request, response: response)
                switch response.result {
                case .success(let data):
                    do {
                        let decoded = try self.decode(type, from: data)
                        NetworkBaseManager.debugLog(request: request)
                        event(.success(decoded))
                    } catch let appDataError {
                        let handled = self.baseErrorHandler?(appDataError) ?? false
                        if !handled {
                            event(.error(appDataError))
                        }
                    }
                case .failure(let error):
                    if let appDataError = self.handleError(error, request: request, httpUrlResponse: response.response) {
                        event(.error(appDataError))
                    }
                }
            })
            return Disposables.create {
                request.cancel()
            }
        })
    }

    private func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        do {
            return try jsonDecoder.decode(type, from: data)
        } catch let error as DecodingError {
            SwiftyBeaver.debug("Decoding failed for: \(String(bytes: data, encoding: .utf8) ?? "")")
            SwiftyBeaver.warning("Decoding error: \(error)")
            throw AppDataError.jsonParsingError(reason: "Failed to decode \(type) data: \(error.localizedDescription)")
        } catch let error {
            SwiftyBeaver.warning("Unexpected error: \(error)")
            throw AppDataError.unknownError(reason: "Failed to decode \(type) data: \(error.localizedDescription)")
        }
    }

    /// Downloads file specified by URL and saves it in a local directory.
    ///
    /// - Parameters:
    ///   - sourceUrl: source URL for the download
    ///   - toDirectory: destination directory
    ///   - subDirectory: Optional path components inside destination directory
    ///   - filename: Optional destination file name
    ///   - queue: The queue on which the request completion handler is dispatched. Default is main queue.
    /// - Returns: Rx Single containing URL of downloaded file
    open func downloadFile(sourceUrl: String,
                           toDirectory: FileManager.SearchPathDirectory = .documentDirectory,
                           subDirectory: String? = nil,
                           filename: String? = nil,
                           queue: DispatchQueue? = nil) -> Single<URL> {
        return Single.create(subscribe: { (event) -> Disposable in
            let destination: DownloadRequest.DownloadFileDestination = { temporaryURL, response in
                let directoryURLs = FileManager.default.urls(for: toDirectory, in: .userDomainMask)
                if directoryURLs.isEmpty {
                    return (temporaryURL, [])
                } else {
                    var destinationURL = directoryURLs[0]
                    if let path = subDirectory {
                        destinationURL = destinationURL.appendingPathComponent(path, isDirectory: true)
                    }
                    destinationURL = destinationURL.appendingPathComponent(filename ?? response.suggestedFilename ?? "temporary")
                    return (destinationURL, [.removePreviousFile, .createIntermediateDirectories])
                }
            }
            let request = Alamofire.download(sourceUrl, to: destination)
            request.validate().responseData(queue: queue, completionHandler: { [weak self] (response) in
//                SwiftyBeaver.verbose("REQUEST: \(request.debugDescription)")
                SwiftyBeaver.verbose("RESPONSE: \(response.debugDescription)")
                self?.handleDownloadResponse(response, request: request, event: event)
            })
            return Disposables.create {
                request.cancel()
            }
        })
    }

    private func handleDownloadResponse(_ response: DownloadResponse<Data>, request: DownloadRequest, event: (SingleEvent<URL>) -> Void) {
        switch response.result {
        case .success:
            NetworkBaseManager.debugLog(request: request)
            if let destinationUrl = response.destinationURL {
                event(.success(destinationUrl))
            } else {
                let appDataError = AppDataError.noData(reason: "No destination URL")
                let handled = self.baseErrorHandler?(appDataError) ?? false
                if !handled {
                    event(.error(appDataError))
                }
            }
        case .failure(let error):
            if let appDataError = self.handleError(error, request: request, httpUrlResponse: response.response) {
                event(.error(appDataError))
            }
        }
    }

    public static func verboseLog(request: DataRequest, response: DataResponse<Data>) {
        SwiftyBeaver.verbose("REQUEST: \(request.debugDescription)")
        if let data = request.request?.httpBody {
            SwiftyBeaver.verbose("REQUEST BODY: \(String(data: data, encoding: .utf8) ?? "")")
        }
        SwiftyBeaver.verbose("RESPONSE: \(response.debugDescription)")
        if let data = response.data {
            SwiftyBeaver.verbose("RESPONSE BODY: \(String(data: data, encoding: .utf8) ?? "")")
        }
    }

    public static func debugLog(request: Request, error: Error? = nil) {
        let requestType = request.request?.httpMethod ?? "Unknown HTTP Method"
        let requestPath = request.request?.url?.lastPathComponent ?? "Unknown URL Path"
        if let error = error {
            SwiftyBeaver.debug("\(requestType) /\(requestPath) call failed: \(error)")
        } else {
            SwiftyBeaver.debug("\(requestType) /\(requestPath) call completed")
        }
    }

    private func handleError(_ error: Error, request: Request, httpUrlResponse: HTTPURLResponse?) -> AppDataError? {
        NetworkBaseManager.debugLog(request: request, error: error)
        let appDataError: AppDataError
        if let appError = error as? AppDataError {
            appDataError = appError
        } else {
            let appErrorCode: Int
            if let httpStatusCode = httpUrlResponse?.statusCode {
                appErrorCode = httpStatusCode
            } else {
                let appError = (error as NSError)
                appErrorCode = (appError.domain == NSURLErrorDomain) ? appError.code : 0
            }
            appDataError = AppDataError.networkError(reason: error.localizedDescription, code: appErrorCode, url: request.request?.url)
        }
        if let baseHandler = self.baseErrorHandler, baseHandler(appDataError) {
            return nil
        } else {
            return appDataError
        }
    }

}
