//
//  File.swift
//  
//
//  Created by Dan ILCA on 12.07.2024.
//

import Foundation
import Combine
import Alamofire

open class NetworkCombineManager: NetworkBaseManager {

    public struct EmptyAppResponse: EmptyResponse, Codable {
        public static func emptyValue() -> NetworkCombineManager.EmptyAppResponse {
            return EmptyAppResponse()
        }
    }

    open func call<T>(_ dataRequest: DataRequest,
                      queue: DispatchQueue = .main,
                      decoder: Alamofire.DataDecoder = JSONDecoder(),
                      emptyResponseCodes: Set<Int> = DecodableResponseSerializer<T>.defaultEmptyResponseCodes) -> AnyPublisher<T, AppDataError> where T: Decodable {
        return Future<T, AppDataError> { promise in
            dataRequest.validate()
                .responseDecodable(of: T.self, queue: queue, decoder: decoder,
                                   emptyResponseCodes: emptyResponseCodes) { [unowned self] dataResponse in
                    Self.verboseLog(request: dataRequest, response: dataResponse)
                    switch dataResponse.result {
                    case .success(let value):
                        Self.debugLog(request: dataRequest)
                        promise(.success(value))
                    case .failure(let error):
                        let appDataError = self.handleError(error, for: dataRequest)
                        promise(.failure(appDataError))
                    }
                }
        }.eraseToAnyPublisher()
    }

    open func callEmptyResponse(_ dataRequest: DataRequest,
                                queue: DispatchQueue = .main) -> AnyPublisher<EmptyAppResponse, AppDataError> {
        return call(dataRequest, emptyResponseCodes: Set(200...205))
    }
}
