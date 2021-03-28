//
//  UserRepository.swift
//  NetworkingCaching
//
//  Created by mickey on 28/03/2021.
//

import Foundation
import Combine

struct UserRepository: Retriever {

    typealias Cdble = UsersResponse
    typealias Rqstr = UserRequester
}

extension UserRepository: UserProvidable {

    func items(forPage page: String) -> AnyPublisher<UsersResponse, NetworkingError> {
        return Self.retrieve(type: Cdble.self, forRequest: Rqstr.items(forPage: page))
    }
}
