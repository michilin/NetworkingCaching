//
//  UsersFactory.swift
//  NetworkingCaching
//
//  Created by mickey on 28/03/2021.
//  
//

import Foundation

enum UsersFactory {

    static func makeScene() -> UsersViewController {
        let vc = UsersViewController(nibName: String(describing: UsersViewController.self), bundle: .main)
        let presenter = UsersPresenter(view: vc)
        let worker = UsersWorker(repository: UserRepository())
        let interactor = UsersInteractor(presenter: presenter, worker: worker)
        let router = UsersRouter()
        router.bind(to: vc)
        vc.bind(to: interactor, and: router)
        return vc
    }
}
