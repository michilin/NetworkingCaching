//
//  UsersRouter.swift
//  NetworkingCaching
//
//  Created by mickey on 28/03/2021.
// 
//

import UIKit

protocol UsersRoutable {}

final class UsersRouter {

    private weak var vc: UIViewController?

    func bind(to vc: UIViewController?) {
        self.vc = vc
    }
}

extension UsersRouter: UsersRoutable {}
