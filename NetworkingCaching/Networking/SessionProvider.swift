//
//  SessionProvider.swift
//  NetworkingCaching
//
//  Created by mickey on 28/03/2021.
//

import Foundation
import Combine

typealias SessionResponse = URLSession.DataTaskPublisher.Output

protocol SessionProvider {
    func response(for request: URLRequest) -> AnyPublisher<SessionResponse, URLError>
}

extension URLSession: SessionProvider {

    func response(for request: URLRequest) -> AnyPublisher<SessionResponse, URLError> {
        return dataTaskPublisher(for: request)
            .eraseToAnyPublisher()
    }
}
