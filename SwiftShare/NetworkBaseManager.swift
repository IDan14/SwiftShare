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

    /// Error handler applied to all encountered errors.
    /// Closure expression returns true if error has been handled and no further handling is required.
    public var baseErrorHandler: ((_ error: Error) -> Bool)?

    public init() {}

    /// Enclose network call as a Rx Completable
    /// - Parameters:
    ///   - dataRequest: Data request to be performed
    ///   - queue: The queue on which the completion handler is dispatched. .main by default.
    /// - Returns: Rx Completable
    open func call(_ dataRequest: DataRequest, queue: DispatchQueue = .main) -> Completable {
        return Completable.create { [weak self] (event) -> Disposable in
            dataRequest.validate().response(queue: queue) { [weak self] (dataResponse) in
                guard let self = self else { return }
                NetworkBaseManager.verboseLog(request: dataRequest, response: dataResponse)
                switch dataResponse.result {
                case .success:
                    NetworkBaseManager.debugLog(request: dataRequest)
                    event(.completed)
                case .failure(let error):
                    if let appDataError = self.handleError(error, for: dataRequest) {
                        event(.error(appDataError))
                    }
                }
            }
            return Disposables.create {
                dataRequest.cancel()
            }
        }

    }

    /// Enclose network call as a Rx Single containing an object created from server response body
    /// - Parameters:
    ///   - dataRequest: Data request to be performed
    ///   - queue: The queue on which the completion handler is dispatched. .main by default.
    ///   - decoder: DataDecoder to use to decode the response. JSONDecoder() by default.
    /// - Returns: Rx Single containing decoded object
    open func call<T>(_ dataRequest: DataRequest, queue: DispatchQueue = .main, decoder: Alamofire.DataDecoder = JSONDecoder()) -> Single<T> where T: Decodable {
        return Single.create { [weak self] (event) -> Disposable in
            dataRequest.validate().responseDecodable(of: T.self, queue: queue, decoder: decoder) { [weak self] (dataResponse) in
                guard let self = self else { return }
                NetworkBaseManager.verboseLog(request: dataRequest, response: dataResponse)
                switch dataResponse.result {
                case .success(let value):
                    NetworkBaseManager.debugLog(request: dataRequest)
                    event(.success(value))
                case .failure(let error):
                    if let appDataError = self.handleError(error, for: dataRequest) {
                        event(.failure(appDataError))
                    }
                }
            }
            return Disposables.create {
                dataRequest.cancel()
            }
        }
    }

    /// Download file specified by URL and save it in a local directory.
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
                           queue: DispatchQueue = .main) -> Single<URL> {
        return Single.create { [weak self ] (event) -> Disposable in
            let destination: DownloadRequest.Destination = { (temporaryURL, response) in
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

            let request = AF.download(sourceUrl, to: destination)
            request.validate().response(queue: queue) { [weak self] (response) in
                guard let self = self else { return }
//                SwiftyBeaver.verbose("REQUEST: \(request.description)")
                SwiftyBeaver.verbose("RESPONSE: \(response.debugDescription)")
                switch response.result {
                case .success(let url):
                    NetworkBaseManager.debugLog(request: request)
                    if let destinationUrl = url {
                        event(.success(destinationUrl))
                    } else {
                        let appDataError = AppDataError.noData(reason: "No destination URL")
                        let handled = self.baseErrorHandler?(appDataError) ?? false
                        if !handled {
                            event(.failure(appDataError))
                        }
                    }
                case .failure(let error):
                    if let appDataError = self.handleError(error, for: request) {
                        event(.failure(appDataError))
                    }
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }

    public static func verboseLog<T>(request: DataRequest, response: DataResponse<T, AFError>) {
        SwiftyBeaver.verbose("REQUEST: \(request.description)")
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
        let requestPath = request.request?.url?.relativeString ?? "Unknown URL"
        if let error = error {
            SwiftyBeaver.debug("\(requestType) /\(requestPath) call failed: \(error)")
        } else {
            SwiftyBeaver.debug("\(requestType) /\(requestPath) call completed")
        }
    }

    private func handleError(_ error: Error, for request: Request) -> AppDataError? {
        NetworkBaseManager.debugLog(request: request, error: error)
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
        if let handler = baseErrorHandler, handler(appDataError) {
            return nil
        } else {
            return appDataError
        }
    }
}
