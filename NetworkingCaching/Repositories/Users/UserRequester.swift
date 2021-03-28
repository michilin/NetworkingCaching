//
//  UserRequester.swift
//  NetworkingCaching
//
//  Created by mickey on 28/03/2021.
//

import Foundation

struct UserRequester: Requester {

    static let root = "https://reqres.in/api/"
    static let endpoint = "users"
}

extension UserRequester {

    static func items(forPage page: String) -> URLRequest? {
        return RequestCreator.createRequest(
            withRoot: root,
            andEndpoint: endpoint,
            httpMethod: .GET,
            body: ["page": page])
    }
}
