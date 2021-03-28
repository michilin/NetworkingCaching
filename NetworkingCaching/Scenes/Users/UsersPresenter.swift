//
//  UsersPresenter.swift
//  NetworkingCaching
//
//  Created by mickey on 28/03/2021.
//  
//

import UIKit

protocol UsersPresentable: class {
    func updateDataSource(_: [User])
    func presentError(_: NetworkingError)
}

final class UsersPresenter {

    private weak var view: UsersViewable?

    init(view: UsersViewable?) {
        self.view = view
    }
}

extension UsersPresenter: UsersPresentable {

    func updateDataSource(_ users: [User]) {
        let cellViewModels = users.map {
            UserCellViewModel(
                avatar: $0.avatar,
                name: ($0.firstName ?? "") + " " + ($0.lastName ?? ""),
                email: $0.email ?? "")
        }
        let viewModel = UsersViewModel(cellViewModels: cellViewModels)
        view?.updateViewModel(viewModel)
    }

    func presentError(_ error: NetworkingError) {
        view?.presentError(error.localizedDescription)
    }
}
