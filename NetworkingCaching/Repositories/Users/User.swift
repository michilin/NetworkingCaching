//
//  User.swift
//  NetworkingCaching
//
//  Created by mickey on 28/03/2021.
//

import Foundation

struct UsersResponse: Codable {
    let page: Int?
    let total: Int?
    let users: [User]?

    enum CodingKeys : String, CodingKey {
        case page
        case total = "total_pages"
        case users = "data"
    }
}

struct User: Codable {
    let id: Int?
    let email: String?
    let firstName: String?
    let lastName: String?
    let avatar: String?

    enum CodingKeys : String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
    }
}
