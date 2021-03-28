//
//  SceneDelegate.swift
//  NetworkingCaching
//
//  Created by mickey on 27/03/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let rootViewController = UsersFactory.makeScene()
        let nav = UINavigationController(rootViewController: rootViewController)
        window.rootViewController = nav
        self.window = window
        window.makeKeyAndVisible()
    }
}

