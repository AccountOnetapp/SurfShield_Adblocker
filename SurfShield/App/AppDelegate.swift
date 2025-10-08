//
//  AppDelegate.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import UIKit
import ApphudSDK

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        Apphud.start(apiKey: Constants.apphudApiKey)
        return true
    }
}

