//
//  UsersWorker.swift
//  NetworkingCaching
//
//  Created by mickey on 28/03/2021.
//  
//

import Foundation
import Combine

typealias UserWorkerResult = (Result<UsersResponse, NetworkingError>) -> Void

protocol UsersWorkable {
    func fetchUsers(for page: Int, completion: @escaping UserWorkerResult)
}

final class UsersWorker {

    private let repository: UserProvidable
    private let subscriptionQueue: DispatchQueue
    private let receivingQueue: DispatchQueue
    private var bag = Set<AnyCancellable>()

    init(
        repository: UserProvidable,
        subscriptionQueue: DispatchQueue = DispatchQueue.global(qos: .background),
        receivingQueue: DispatchQueue = .main
    ) {
        self.repository = repository
        self.subscriptionQueue = subscriptionQueue
        self.receivingQueue = receivingQueue
    }
}

extension UsersWorker: UsersWorkable {

    func fetchUsers(for page: Int, completion: @escaping UserWorkerResult) {
        repository.items(forPage: String(page))
            .subscribe(on: subscriptionQueue)
            .receive(on: receivingQueue)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { value in
                completion(.success(value))
            })
            .store(in: &bag)
    }
}
