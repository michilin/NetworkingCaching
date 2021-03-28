//
//  UserProvidable.swift
//  NetworkingCaching
//
//  Created by mickey on 28/03/2021.
//

import Foundation
import Combine

protocol UserProvidable {
    func items(forPage page: String) -> AnyPublisher<UsersResponse, NetworkingError>
}
