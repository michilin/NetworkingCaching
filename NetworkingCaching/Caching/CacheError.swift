//
//  CacheError.swift
//  NetworkingCaching
//
//  Created by mickey on 27/03/2021.
//

import Foundation

public enum CacheError: Error, LocalizedError {

    case directoryNotFound
    case unparseable

    public var errorDescription: String? {
        switch self {
        case .directoryNotFound: return "Directory not found"
        case .unparseable: return "Unable to parse"
        }
    }
}
