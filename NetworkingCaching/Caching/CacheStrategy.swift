//
//  CacheStrategy.swift
//  NetworkingCaching
//
//  Created by mickey on 27/03/2021.
//

import Foundation

enum CacheStrategy {
    case localOrRemoteIfExpired
    case localAndRemoteIfExpired
    case localAndRemote
    case localAndForcedRemote
    case remote
    case remoteWithoutCachingResponse
}
