//
//  RetrieverTests.swift
//  NetworkingCachingTests
//
//  Created by mickey on 27/03/2021.
//

import XCTest
import Combine
@testable import NetworkingCaching

final class RetrieverTests: XCTestCase {

    private var bag = Set<AnyCancellable>()

    override func tearDown() {
        mockCache.reset()
        super.tearDown()
    }

    func test_retrieve_localOrRemoteIfExpiredStrategyAndHasLocal_dontSaveToCacheAndReturnLocal() {
        mockCache.shouldReturnedFile = true
        let expectation = XCTestExpectation(description: "onNext emits")
        MockRetriever.retrieve(type: TestObject.self, forRequest: MockRetriever.request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Should be success: \(error)")
                }
            }, receiveValue: { object in
                XCTAssertNil(mockCache.savedFileName)
                XCTAssertNotNil(mockCache.readFileName)
                XCTAssertEqual(object.id, TestObject.local.id)
            })
            .store(in: &bag)
        wait(for: [expectation], timeout: 0.01)
    }

    func test_retrieve_localOrRemoteIfExpiredStrategyAndHasNoLocal_savedToCacheAndReturnRemote() {
        let expectation = XCTestExpectation(description: "onNext emits")
        MockRetriever.retrieve(type: TestObject.self, forRequest: MockRetriever.request)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Should be success: \(error)")
                }
            }, receiveValue: { object in
                XCTAssertNotNil(mockCache.savedFileName)
                XCTAssertNotNil(mockCache.readFileName)
                XCTAssertEqual(object.id, TestObject.remote.id)
            })
            .store(in: &bag)
        wait(for: [expectation], timeout: 0.01)
    }

    func test_retrieve_localAndRemoteIfExpiredStrategyAndHasLocal_dontSaveToCacheAndReturnLocal() {
        mockCache.shouldReturnedFile = true
        let expectation = XCTestExpectation(description: "onNext emits")
        MockRetriever.retrieve(type: TestObject.self, forRequest: MockRetriever.request, strategy: .localAndRemoteIfExpired)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Should be success: \(error)")
                }
            }, receiveValue: { object in
                XCTAssertNil(mockCache.savedFileName)
                XCTAssertNotNil(mockCache.readFileName)
                XCTAssertEqual(object.id, TestObject.local.id)
            })
            .store(in: &bag)
        wait(for: [expectation], timeout: 0.01)
    }

    func test_retrieve_localAndRemoteIfExpiredStrategyAndHasNoLocal_savedToCacheAndReturnRemote() {
        let expectation = XCTestExpectation(description: "onNext emits")
        MockRetriever.retrieve(type: TestObject.self, forRequest: MockRetriever.request, strategy: .localAndRemoteIfExpired)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Should be success: \(error)")
                }
            }, receiveValue: { object in
                XCTAssertNotNil(mockCache.savedFileName)
                XCTAssertNotNil(mockCache.readFileName)
                XCTAssertEqual(object.id, TestObject.remote.id)
            })
            .store(in: &bag)
        wait(for: [expectation], timeout: 0.01)
    }

    func test_retrieve_localAndRemoteStrategyAndHasLocal_savedToCacheAndConcatLocalAndRemote() {
        mockCache.shouldReturnedFile = true
        let expectation = XCTestExpectation(description: "onNext emits")
        var emitCount = 0
        MockRetriever.retrieve(type: TestObject.self, forRequest: MockRetriever.request, strategy: .localAndRemote)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Should be success: \(error)")
                }
            }, receiveValue: { object in
                XCTAssertNotNil(mockCache.readFileName)
                emitCount += 1
                if emitCount == 1 {
                    XCTAssertEqual(object.id, TestObject.local.id)
                } else if emitCount == 2 {
                    XCTAssertNotNil(mockCache.savedFileName)
                    XCTAssertEqual(object.id, TestObject.remote.id)
                }
            })
            .store(in: &bag)
        wait(for: [expectation], timeout: 0.01)
    }

    func test_retrieve_remoteStrategyAndHasLocal_dontReadFromCacheAndReturnRemote() {
        mockCache.shouldReturnedFile = true
        let expectation = XCTestExpectation(description: "onNext emits")
        MockRetriever.retrieve(type: TestObject.self, forRequest: MockRetriever.request, strategy: .remote)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Should be success: \(error)")
                }
            }, receiveValue: { object in
                XCTAssertNotNil(mockCache.savedFileName)
                XCTAssertNil(mockCache.readFileName)
                XCTAssertEqual(object.id, TestObject.remote.id)
            })
            .store(in: &bag)
        wait(for: [expectation], timeout: 0.01)
    }

    func test_retrieve_remoteWithoutCachingResponseStrategyAndHasLocal_dontReadFromCacheAndDontSaveToCacheAndReturnRemote() {
        mockCache.shouldReturnedFile = true
        let expectation = XCTestExpectation(description: "onNext emits")
        MockRetriever.retrieve(type: TestObject.self, forRequest: MockRetriever.request, strategy: .remoteWithoutCachingResponse)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Should be success: \(error)")
                }
            }, receiveValue: { object in
                XCTAssertNil(mockCache.savedFileName)
                XCTAssertNil(mockCache.readFileName)
                XCTAssertEqual(object.id, TestObject.remote.id)
            })
            .store(in: &bag)
        wait(for: [expectation], timeout: 0.01)
    }
}

// MARK: - Mocks

private let mockCache = MockCache()
private let mockApiProvider = MockApiProvider()

private let url: URL! = URL(string: "https://www.google.com/")

private final class MockRequester: Requester {

    static let root = url.absoluteString
    static let endpoint = "test"
}

private final class MockRetriever: Retriever {

    typealias Cdble =  TestObject
    typealias Rqstr = MockRequester

    class var cacher: Cachable {
        return mockCache
    }

    class var sessionProvider: SessionProvider {
        return mockApiProvider
    }
    static var request: URLRequest {
        RequestCreator.createRequest(
            withRoot: MockRequester.root,
            andEndpoint: MockRequester.endpoint,
            httpMethod: .GET)
    }
}

private final class MockApiProvider: SessionProvider {

    func response(for request: URLRequest) -> AnyPublisher<SessionResponse, URLError> {
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil)!
        let data = TestObject.remoteData!
        return Just((data: data, response: response))
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
    }
}
