//
//  Cache.swift
//  NetworkingCaching
//
//  Created by mickey on 27/03/2021.
//

import Foundation

enum CacheDeletionStrategy {
    case all, privateOnly, outdatedOnly, allNonPrivate
}

protocol Cachable {
    func save(
        _ file: String,
        with fileName: String,
        fileCanBeExpired: Bool,
        expiresAt: Int64
    ) throws
    func readItem(with fileName: String, includeExpired: Bool) -> (file: String?, expired: Bool)
    func readItems(with baseFileName: String) -> [String]
    func deleteItem(with fileName: String)
    func clearItems(deletionStrategy: CacheDeletionStrategy, completion: (() -> Void)?)
}

struct Cache: Cachable {

    private let fileManager: FileManager
    private let clearCacheQueue: DispatchQueue

    private static let second: Int64 = 6000
    private static let minute: Int64 = second * 60
    private static let hour: Int64 = minute * 60
    private static let day: Int64 = hour * 24
    private static let cacheDuration: Int64 = minute * 10
    private static let fileDuration: Int64 = day * 2
    static let defaultExpiresAt = Date().toMilliseconds() + cacheDuration
    static let fileExtension: String = ".diskcache"
    static let privateIndicator: String = "-private"

    enum FileComponentKey {
        case expiry, file
    }

    init(
        fileManager: FileManager = .default,
        clearCacheQueue: DispatchQueue = DispatchQueue.global(qos: .background)
    ) {
        self.fileManager = fileManager
        self.clearCacheQueue = clearCacheQueue
    }

    func save(
        _ file: String,
        with fileName: String,
        fileCanBeExpired: Bool,
        expiresAt: Int64
    ) throws {
        let fileUrl = try getFileUrl(fileName)
        let expiryTimestamp = fileCanBeExpired ? "\(expiresAt)" : "NA"
        let text = "\(expiryTimestamp)|\(file)"
        try text.write(to: fileUrl, atomically: false, encoding: .utf8)
    }

    func readItem(with fileName: String, includeExpired: Bool) -> (file: String?, expired: Bool) {
        guard let fileUrl = try? getFileUrl(fileName) else {
            return (file: nil, expired: false)
        }
        do {
            let text = try String(contentsOf: fileUrl, encoding: .utf8)
            let expired = isFileExpired(text)
            if !includeExpired && expired {
                return (file: nil, expired: true)
            }
            let file = getFileComponent(by: .file, from: text)
            return (file: file, expired: expired)
        } catch {
            return (file: nil, expired: false)
        }
    }

    func readItems(with baseFileName: String) -> [String] {
        guard let files = try? getAllFilesUrl() else { return [] }
        return files
            .filter { return $0.lastPathComponent.starts(with: baseFileName) }
            .map { try? String(contentsOf: $0.absoluteURL, encoding: .utf8) }
            .compactMap { $0 }
            .map { return getFileComponent(by: .file, from: $0) }
            .compactMap { $0 }
    }

    func deleteItem(with fileName: String) {
        guard let fileUrl = try? getFileUrl(fileName) else { return }
        try? fileManager.removeItem(at: fileUrl)
    }

    func clearItems(deletionStrategy: CacheDeletionStrategy, completion: (() -> Void)?) {
        guard let files = try? getAllFilesUrl() else { return }
        let fullExtension = deletionStrategy == .privateOnly
            ? "\(Self.privateIndicator)\(Self.fileExtension)"
            : "\(Self.fileExtension)"
        clearCacheQueue.async {
            files
                .filter { $0.absoluteString.contains(fullExtension) }
                .forEach {
                    var shouldDelete = false
                    switch deletionStrategy {
                    case .all, .privateOnly:
                        shouldDelete = true
                    case .allNonPrivate:
                        shouldDelete = !$0.absoluteString.contains("\(Self.privateIndicator)")
                    case .outdatedOnly:
                        guard let text = try? String(contentsOf: $0.absoluteURL, encoding: .utf8) else { return }
                        shouldDelete = isFileExpired(text, and: true)
                    }
                    if shouldDelete {
                        try? fileManager.removeItem(atPath: $0.path)
                    }
                }
            completion?()
        }
    }

    // MARK: - Private helpers

    private func getFileUrl(_ fileName: String) throws -> URL {
        guard let dir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            throw CacheError.directoryNotFound
        }
        return dir.appendingPathComponent("\(fileName)\(Self.fileExtension)")
    }

    private func getAllFilesUrl() throws -> [URL] {
        guard
            let dir = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first,
            let files = try? fileManager.contentsOfDirectory(
                at: dir,
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles)
        else {
            throw CacheError.directoryNotFound
        }
        return files
    }

    private func isFileExpired(_ file: String, and alsoOutdated: Bool = false) -> Bool {
        guard let expiry = getFileComponent(by: .expiry, from: file) else { return true }
        guard let expiryDate = Int64(expiry) else { return false }
        let currentDate = Int64(Date().toMilliseconds())
        if alsoOutdated {
            return currentDate - expiryDate > Self.fileDuration
        } else {
            return currentDate > expiryDate
        }
    }

    private func getFileComponent(by key: FileComponentKey, from text: String) -> String? {
        let components = text.split(separator: "|", maxSplits: 1, omittingEmptySubsequences: true)
        guard components.count == 2 else { return nil }
        switch key {
        case .expiry:
            return String(components[0])
        case .file:
            return String(components[1])
        }
    }
}

extension Date {

    func toMilliseconds() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}
