//
//  File.swift
//  
//
//  Created by Dan ILCA on 12.07.2024.
//

import Foundation
import RxSwift
import Alamofire

open class NetworkRxSwiftManager: NetworkBaseManager {

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
                    let appDataError = self.handleError(error, for: dataRequest)
                    event(.error(appDataError))
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
                    let appDataError = self.handleError(error, for: dataRequest)
                    event(.failure(appDataError))
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
//                logger.verbose("REQUEST: \(request.description)")
                logger.verbose("RESPONSE: \(response.debugDescription)")
                switch response.result {
                case .success(let url):
                    NetworkBaseManager.debugLog(request: request)
                    if let destinationUrl = url {
                        event(.success(destinationUrl))
                    } else {
                        let appDataError = self.handleError(AppDataError.noData(reason: "No destination URL"), for: request)
                        event(.failure(appDataError))
                    }
                case .failure(let error):
                    let appDataError = self.handleError(error, for: request)
                    event(.failure(appDataError))
                }
            }

            return Disposables.create {
                request.cancel()
            }
        }
    }
}
