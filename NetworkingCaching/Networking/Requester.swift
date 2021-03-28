//
//  Requester.swift
//  NetworkingCaching
//
//  Created by mickey on 27/03/2021.
//

import Foundation

protocol Requester {
    static var root: String { get }
    static var endpoint: String { get }
}
