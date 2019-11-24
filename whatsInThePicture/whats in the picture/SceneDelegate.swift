//
//  SceneDelegate.swift
//  whats in the picture
//
//  Created by nic Wanavit on 11/23/19.
//  Copyright © 2019 Wanavit. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName: "PhotoModel")


   func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        dataController.load()
        let navigationController = window?.rootViewController as! UINavigationController
        let overviewViewController = navigationController.topViewController as! OverviewViewController
        overviewViewController.dataController = dataController
        print("app finished loading")
        guard let _ = (scene as? UIWindowScene) else { return }
    }


}

