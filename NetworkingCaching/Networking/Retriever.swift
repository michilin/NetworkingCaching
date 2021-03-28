//
//  Retriever.swift
//  NetworkingCaching
//
//  Created by mickey on 27/03/2021.
//

import Foundation
import Combine

protocol Retriever {
    associatedtype Cdble: Codable
    associatedtype Rqstr: Requester

    static var cacher: Cachable { get }
    static var sessionProvider: SessionProvider { get }
}

extension Retriever {

    static var cacher: Cachable {
        return Cache()
    }

    static var cacheCodableInterface: CacheCodableInterface {
        return CacheCodableInterface(cacher: cacher)
    }

    static var sessionProvider: SessionProvider {
        return URLSession.shared
    }

    static func retrieve<Model: Codable>(
        type: Model.Type,
        forRequest request: URLRequest?,
        isPrivateObject: Bool = false,
        strategy: CacheStrategy = .localOrRemoteIfExpired
    ) -> AnyPublisher<Model, NetworkingError> {
        guard let request = request else {
            return Fail(error: NetworkingError.generateUrlError).eraseToAnyPublisher()
        }
        let fileName = isPrivateObject ? request.identifier + Cache.privateIndicator : request.identifier
        let theRemote = remote(
            of: type.self,
            forRequest: request,
            cacheStrategy: strategy,
            fileName: fileName)

        switch strategy {
        case .localOrRemoteIfExpired:
            guard let theLocal = local(of: type.self, fileName: fileName).object else {
                return theRemote
            }
            return theLocal
        case .localAndRemoteIfExpired, .localAndRemote, .localAndForcedRemote:
            let cacheResponse = local(of: type.self, fileName: fileName, includeExpired: true)
            guard let theLocal = cacheResponse.object else { return theRemote }
            if
                strategy == .localAndRemote ||
                strategy == .localAndForcedRemote ||
                cacheResponse.expired {
                return theRemote
                    .prepend(theLocal)
                    .eraseToAnyPublisher()
            } else {
                return theLocal
            }
        case .remote, .remoteWithoutCachingResponse:
            return theRemote
        }
    }

    private static func local<Model: Codable>(
        of type: Model.Type,
        fileName: String,
        includeExpired: Bool = false
    ) -> (object: AnyPublisher<Model, NetworkingError>?, expired: Bool) {
        let local = cacheCodableInterface.local(
            of: type,
            fileName: fileName,
            includeExpired: includeExpired)
        guard let localObject = local.object else {
            return (object: nil, expired: false)
        }
        return (object: Just(localObject)
                    .setFailureType(to: NetworkingError.self)
                    .eraseToAnyPublisher(),
                expired: local.expired)
    }

    private static func remote<Model: Codable>(
        of type: Model.Type,
        forRequest request: URLRequest,
        cacheStrategy: CacheStrategy,
        fileName: String
    ) -> AnyPublisher<Model, NetworkingError> {
        var request = request
        if cacheStrategy == .localAndForcedRemote {
            request.cachePolicy = .reloadIgnoringLocalCacheData
        }
        return sessionProvider.response(for: request)
            .mapError { error in
                .requestError(error)
            }
            .flatMap(maxPublishers: .max(1)) { pair -> AnyPublisher<Model, NetworkingError> in
                if cacheStrategy != .remoteWithoutCachingResponse {
                    saveToCache(of: type, with: pair.data, as: fileName)
                }
                return decode(data: pair.data)
            }
            .eraseToAnyPublisher()
    }

    private static func decode<Model: Codable>(data: Data) -> AnyPublisher<Model, NetworkingError> {
        return Just(data)
            .decode(type: Model.self, decoder: JSONDecoder())
            .mapError { error in
                .decodeError(error)
            }
            .eraseToAnyPublisher()
    }

    private static func saveToCache<Model: Codable>(of type: Model.Type, with data: Data, as fileName: String) {
        guard let object = try? cacheCodableInterface.decode(data: data, to: type.self) else {
            return
        }
        try? cacheCodableInterface.save(object, with: fileName, canFileBeExpired: true)
    }
}
