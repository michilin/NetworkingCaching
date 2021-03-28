//
//  CacheCodableInterfaceTests.swift
//  NetworkingCachingTests
//
//  Created by mickey on 27/03/2021.
//

import XCTest
@testable import NetworkingCaching

final class CacheCodableInterfaceTests: XCTestCase {

    private var cache: MockCache!
    private var sut: CacheCodableInterface!

    private let fileName = "test_file"

    override func setUp() {
        super.setUp()
        cache = MockCache()
        sut = CacheCodableInterface(cacher: cache)
    }

    override func tearDown() {
        sut = nil
        cache = nil
        super.tearDown()
    }

    func test_local_fileExists() {
        cache.shouldReturnedFile = true
        let reesult = sut.local(of: TestObject.self, fileName: fileName)
        XCTAssertEqual(cache.readFileName, fileName)
        XCTAssertEqual(reesult.object?.id, TestObject.local.id)
    }

    func test_local_fileDoesntExist() {
        let reesult = sut.local(of: TestObject.self, fileName: fileName)
        XCTAssertEqual(cache.readFileName, fileName)
        XCTAssertNil(reesult.object)
    }

    func test_localItems_filesExist() {
        cache.shouldReturnedFile = true
        let result = sut.localItems(of: TestObject.self, with: fileName)
        XCTAssertEqual(cache.readBaseFileName, fileName)
        XCTAssertEqual(result.first?.id, TestObject.local.id)
    }

    func test_localItems_filesDontExist() {
        let result = sut.localItems(of: TestObject.self, with: fileName)
        XCTAssertEqual(cache.readBaseFileName, fileName)
        XCTAssertTrue(result.isEmpty)
    }

    func test_save() throws {
        try sut.save(TestObject.local, with: fileName)
        XCTAssertEqual(cache.savedFileName, fileName)
    }
}
