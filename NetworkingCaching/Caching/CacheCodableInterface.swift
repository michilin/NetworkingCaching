//
//  CacheCodableInterface.swift
//  NetworkingCaching
//
//  Created by mickey on 27/03/2021.
//

import Foundation

struct CacheCodableInterface {

    private let cacher: Cachable

    init(cacher: Cachable = Cache()) {
        self.cacher = cacher
    }

    func local<Model: Codable>(
        of type: Model.Type,
        fileName: String,
        includeExpired: Bool = false
    ) -> (object: Model?, expired: Bool) {
        let cache = cacher.readItem(with: fileName, includeExpired: includeExpired)
        guard
            let file = cache.file,
            let data = file.data(using: .utf8),
            let json = try? decode(data: data, to: Model.self)
        else {
            return (object: nil, expired: false)
        }
        return (object: json, expired: cache.expired)
    }

    func localItems<Model: Codable>(
        of type: Model.Type,
        with baseFileName: String
    ) -> [Model] {
        return cacher
            .readItems(with: baseFileName)
            .map {
                guard let data = $0.data(using: .utf8) else { return nil }
                return try? decode(data: data, to: Model.self)
            }
            .compactMap { $0 }
    }

    func save<Model: Codable>(
        _ object: Model,
        with fileName: String,
        canFileBeExpired: Bool = true
    ) throws {
        guard
            let jsonData = try? JSONEncoder().encode(object),
            let file = String(data: jsonData, encoding: .utf8)
        else {
            return
        }
        try cacher.save(
            file,
            with: fileName,
            fileCanBeExpired: canFileBeExpired,
            expiresAt: Cache.defaultExpiresAt)
    }

    func decode<Model: Codable>(
        data: Data,
        to type: Model.Type
    ) throws -> Model {
        do {
            return try JSONDecoder().decode(Model.self, from: data)
        } catch {
            print(error)
            throw CacheError.unparseable
        }
    }
}
