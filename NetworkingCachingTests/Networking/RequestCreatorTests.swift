//
//  RequestCreatorTests.swift
//  NetworkingCachingTests
//
//  Created by mickey on 27/03/2021.
//

import XCTest
@testable import NetworkingCaching

final class RequestCreatorTests: XCTestCase {

    private let root = "https://www.google.com/"
    private let endpoint = "test"
    private let integer = 1
    private let double = 11.11
    private let string = "body"
    private let plusString = "a+b"
    private let array =  ["1", "2", "3"]
    private lazy var body: [String: Any] = [
        "integer": integer,
        "double": double,
        "string": string,
        "plusString": plusString,
        "array": array
    ]

    func test_createRequest_withoutHeadersAndBody_expectingRootAppendingEndpoint() {
        let expectedResult = root + endpoint
        HttpMethod.allCases.forEach {
            let request = RequestCreator.createRequest(
                withRoot: root,
                andEndpoint: endpoint,
                httpMethod: $0)
            XCTAssertEqual(request.url?.absoluteString, expectedResult)
        }
    }

    func test_createRequest_withHeaders_headersAreInserted() {
        let headers = ["header": "This is a header"]
        HttpMethod.allCases.forEach {
            let request = RequestCreator.createRequest(
                withRoot: root,
                andEndpoint: endpoint,
                httpMethod: $0,
                headers: headers)
            XCTAssertEqual(request.allHTTPHeaderFields?["header"], headers["header"])
        }
    }

    func test_createRequest_withBodyAndGetHttpMethod_queryItemsAreInserted() {
        let bodyString = body
            .sorted(by: { $0.key < $1.key })
            .map { (key, value) in
                if let arrayValue = value as? [String] {
                    return arrayValue
                        .map { key + "=" + $0 }
                        .joined(separator: "&")
                } else {
                    return key + "=" + String(describing: value)
                }
            }
            .joined(separator: "&")
            .replacingOccurrences(of: "+", with: "%2B")
        let expectedResult = root + endpoint + "?" + bodyString
        let request = RequestCreator.createRequest(
            withRoot: root,
            andEndpoint: endpoint,
            httpMethod: .GET,
            body: body)
        XCTAssertNil(request.httpBody)
        XCTAssertEqual(request.url?.absoluteString, expectedResult)
    }

    func test_createRequest_withBodyAndPostHttpMethod_bodyDataIsInserted() throws {
        let request = RequestCreator.createRequest(
            withRoot: root,
            andEndpoint: endpoint,
            httpMethod: .POST,
            body: body)
        let returnedBodyData = try XCTUnwrap(request.httpBody)
        let json = try JSONSerialization.jsonObject(
            with: returnedBodyData,
        options: []) as? [String: Any]
        XCTAssertEqual(json?.keys, body.keys)
        let returnedInteger = try XCTUnwrap(json?["integer"] as? Int)
        XCTAssertEqual(returnedInteger, integer)
        let returnedDouble = try XCTUnwrap(json?["double"] as? Double)
        XCTAssertEqual(returnedDouble, double)
        let returnedString = try XCTUnwrap(json?["string"] as? String)
        XCTAssertEqual(returnedString, string)
        let returnedPlusString = try XCTUnwrap(json?["plusString"] as? String)
        XCTAssertEqual(returnedPlusString, plusString)
        let returnedArray = try XCTUnwrap(json?["array"] as? [String])
        XCTAssertEqual(returnedArray, array)
    }

    func test_createRequest_withBodyData_bodyDataIsInserted() {
        HttpMethod.allCases.forEach {
            let request = RequestCreator.createRequest(
                withRoot: root,
                andEndpoint: endpoint,
                httpMethod: $0,
                bodyData: Data())
            XCTAssertNotNil(request.httpBody)
        }
    }
}
