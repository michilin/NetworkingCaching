//
//  NetworkingError.swift
//  NetworkingCaching
//
//  Created by mickey on 27/03/2021.
//

import Foundation

enum NetworkingError: Error {
    case generateUrlError
    case decodeError(_ error: Error)
    case requestError(_ error: Error)
}
