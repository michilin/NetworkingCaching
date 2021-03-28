//
//  UsersViewModel.swift
//  NetworkingCaching
//
//  Created by mickey on 28/03/2021.
//  
//

import Foundation

struct UsersViewModel {
    let cellViewModels: [UserCellViewModel]
}

struct UserCellViewModel {
    let avatar: String?
    let name: String
    let email: String
}
