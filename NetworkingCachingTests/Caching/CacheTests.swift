//
//  CacheTests.swift
//  NetworkingCachingTests
//
//  Created by mickey on 27/03/2021.
//

import XCTest
@testable import NetworkingCaching

final class CacheTests: XCTestCase {

    private var fileManager: MockFileManager!
    private var clearCacheQueue: DispatchQueue!
    private var sut: Cache!

    private let file = "to_save_content"
    private let fileName = "test_file"
    private let privateFileName = "private_test_file" + Cache.privateIndicator
    private let expiresAt: Int64 = Date().toMilliseconds() + 3000

    private var expectedSavedPath: URL {
        fileManager.temporaryDirectory.appendingPathComponent("\(fileName)\(Cache.fileExtension)")
    }
    private var expectedSavedPrivateObjectPath: URL {
        fileManager.temporaryDirectory.appendingPathComponent("\(privateFileName)\(Cache.fileExtension)")
    }

    override func setUpWithError() throws {
        try super.setUpWithError()
        fileManager = MockFileManager()
        clearCacheQueue = DispatchQueue(label: "DiskCacheTests Clear Cache Queue")
        sut = Cache(fileManager: fileManager, clearCacheQueue: clearCacheQueue)
    }

    override func tearDownWithError() throws {
        if fileManager.fileExists(atPath: expectedSavedPath.path) {
            try fileManager.removeItem(at: expectedSavedPath)
        }
        if fileManager.fileExists(atPath: expectedSavedPrivateObjectPath.path) {
            try fileManager.removeItem(at: expectedSavedPrivateObjectPath)
        }
        sut = nil
        clearCacheQueue = nil
        fileManager = nil
        try super.tearDownWithError()
    }

    func test_save_fileCanBeExpired_savedContentWithExpiresAtTimestamp() throws {
        try saveTemporaryFile()
        let savedContent = try String(contentsOf: expectedSavedPath, encoding: .utf8)
        XCTAssertEqual(savedContent, "\(expiresAt)|\(file)")
    }

    func test_save_fileCannotBeExpired_saveContentWithNATimestamp() throws {
        try saveTemporaryFile(fileCanBeExpired: false)
        let savedContent = try String(contentsOf: expectedSavedPath, encoding: .utf8)
        XCTAssertEqual(savedContent, "NA|\(file)")
    }

    func test_readItem_fileExistsAndHasNotExpiredYet_returnFileAndNotExpired() throws {
        try saveTemporaryFile()
        let result = sut.readItem(with: fileName, includeExpired: false)
        XCTAssertEqual(result.file, file)
        XCTAssertFalse(result.expired)
    }

    func test_readItem_fileExistsButHasExpired_returnNilAndExpired() throws {
        try saveTemporaryFile(hasExpired: true)
        let result = sut.readItem(with: fileName, includeExpired: false)
        XCTAssertNil(result.file)
        XCTAssertTrue(result.expired)
    }

    func test_readItem_fileDoesNotExist_returnNilAndNotExpired() throws {
        let result = sut.readItem(with: fileName, includeExpired: false)
        XCTAssertNil(result.file)
        XCTAssertFalse(result.expired)
    }

    func test_readItems_baseNameExists_returnFiles() throws {
        try saveTemporaryFile()
        let items = sut.readItems(with: fileName)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first, file)
    }

    func test_readItems_baseNameDoesntExist_returnEmptyFiles() throws {
        let items = sut.readItems(with: fileName)
        XCTAssertTrue(items.isEmpty)
    }

    func test_deleteItem_fileExists_fileIsRemovedFromDirectory() throws {
        try saveTemporaryFile()
        sut.deleteItem(with: fileName)
        XCTAssertFalse(fileManager.fileExists(atPath: expectedSavedPath.path))
    }

    func test_clearItems_deleteAll_allFilesAreRemoved() throws {
        try saveTemporaryFile(saveAnotherPrivateObject: true)
        let expectation = XCTestExpectation(description: "Complete delete items")
        sut.clearItems(deletionStrategy: .all) { [self] in
            XCTAssertFalse(fileManager.fileExists(atPath: expectedSavedPath.path))
            XCTAssertFalse(fileManager.fileExists(atPath: expectedSavedPrivateObjectPath.path))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    func test_clearItems_deletePrivateOnly_normalFileIsStillExisted() throws {
        try saveTemporaryFile(saveAnotherPrivateObject: true)
        let expectation = XCTestExpectation(description: "Complete delete items")
        sut.clearItems(deletionStrategy: .privateOnly) { [self] in
            XCTAssertTrue(fileManager.fileExists(atPath: expectedSavedPath.path))
            XCTAssertFalse(fileManager.fileExists(atPath: expectedSavedPrivateObjectPath.path))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    func test_clearItems_deleteAllNonPrivate_privateFileIsStillExisted() throws {
        try saveTemporaryFile(saveAnotherPrivateObject: true)
        let expectation = XCTestExpectation(description: "Complete delete items")
        sut.clearItems(deletionStrategy: .allNonPrivate) { [self] in
            XCTAssertFalse(fileManager.fileExists(atPath: expectedSavedPath.path))
            XCTAssertTrue(fileManager.fileExists(atPath: expectedSavedPrivateObjectPath.path))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    func test_clearItems_deleteOutdatedOnly_nonExpiredFileIsStillExisted() throws {
        try saveTemporaryFile(hasExpired: true, saveAnotherPrivateObject: true)
        let expectation = XCTestExpectation(description: "Complete delete items")
        sut.clearItems(deletionStrategy: .outdatedOnly) { [self] in
            XCTAssertTrue(fileManager.fileExists(atPath: expectedSavedPath.path))
            XCTAssertTrue(fileManager.fileExists(atPath: expectedSavedPrivateObjectPath.path))
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.01)
    }

    private func saveTemporaryFile(
        fileCanBeExpired: Bool = true,
        hasExpired: Bool = false,
        saveAnotherPrivateObject: Bool = false
    ) throws {
        try sut.save(
            file,
            with: fileName,
            fileCanBeExpired: fileCanBeExpired,
            expiresAt: hasExpired ? Date().toMilliseconds() - 30 : expiresAt)
        if saveAnotherPrivateObject {
            try sut.save(
                file,
                with: privateFileName,
                fileCanBeExpired: fileCanBeExpired,
                expiresAt: hasExpired ? Date().toMilliseconds() - 30 : expiresAt)
        }
    }
}

// MARK: - Mocks

private final class MockFileManager: FileManager {

    override func urls(for directory: FileManager.SearchPathDirectory, in domainMask: FileManager.SearchPathDomainMask) -> [URL] {
        return [temporaryDirectory]
    }
}
