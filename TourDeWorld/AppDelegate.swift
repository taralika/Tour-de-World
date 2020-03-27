//
//  AppDelegate.swift
//  Tour de World
//
//  Created by taralika on 3/23/20.
//  Copyright © 2020 at. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        DataController.shared.load()
        
        let navigationController = window?.rootViewController as! UINavigationController
        let mapViewController = navigationController.topViewController as! MapViewController
        mapViewController.dataController = DataController.shared
        return true
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
        DataController.shared.saveContext()
    }
}
