//
//  String+Identifier.swift
//  NetworkingCaching
//
//  Created by mickey on 27/03/2021.
//

import Foundation
import CryptoKit

extension String {

    var sha256: String {
        data(using: .utf8).map { SHA256.hash(data: $0).hexString } ?? ""
    }
}

extension Digest {

    var hexString: String {
        Array(makeIterator())
            .map { String(format: "%02X", $0) }
            .joined()
    }
}

public extension URLRequest {

    var identifier: String {
        guard let url = url else { return "" }
        var string = url.absoluteString
        if let httpMethod = httpMethod {
            string += httpMethod
        }
        if let allHTTPHeaderFields = allHTTPHeaderFields {
            let safeHeaderFields = allHTTPHeaderFields
                .filter { $0.key != "Authorization" }
                .sorted { $0.key < $1.key }
                .map { "\($0.key)=\($0.value)" }
                .joined(separator: ",")
            string += safeHeaderFields.description
        }
        if
            let httpBody = httpBody,
            let bodyString = String(data: httpBody, encoding: .utf8) {
            string += bodyString
        }
        return string.sha256
    }
}
