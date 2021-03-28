//
//  UsersInteractor.swift
//  NetworkingCaching
//
//  Created by mickey on 28/03/2021.
//  
//

import Foundation

protocol UsersInteractable {
    func fetchUsers()
}

final class UsersInteractor {

    private let presenter: UsersPresentable
    private let worker: UsersWorkable

    private var users: [User] = []
    private var currentPage = 1
    private var totalPage: Int = .max

    init(presenter: UsersPresentable, worker: UsersWorkable) {
        self.presenter = presenter
        self.worker = worker
    }

    private func updateUsersAndPageData(_ response: UsersResponse) {
        currentPage == 1
            ? users = response.users ?? []
            : users.append(contentsOf: response.users ?? [])
        totalPage = response.total ?? 0
        currentPage += 1
        presenter.updateDataSource(users)
    }
}

extension UsersInteractor: UsersInteractable {

    func fetchUsers() {
        guard currentPage <= totalPage else { return }
        worker.fetchUsers(for: currentPage) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.updateUsersAndPageData(response)
            case .failure(let error):
                self.presenter.presentError(error)
            }
        }
    }
}
