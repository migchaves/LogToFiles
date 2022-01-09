//
//  AppDelegate.swift
//  LogToFiles
//
//  Created by Miguel on 09/01/2022.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            
            print("----- APP START -----\n\nDate: \(Date())\n\n", to: &Log.log)
            
            return true
        }
}
