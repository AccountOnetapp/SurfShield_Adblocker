//
//  AppDelegate.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import UIKit
import ApphudSDK

class AppDelegate: NSObject, UIApplicationDelegate {
    
    private let purchaseService = PurchaseService()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        // Получаем IDFV (Identifier for Vendor)
        let idfv = UIDevice.current.identifierForVendor?.uuidString
        
        // Инициализация AppHud с IDF
        Apphud.start(apiKey: Constants.apphudApiKey)
//        Apphud.startManually(apiKey: Constants.apphudApiKey, deviceID: idfv)
        
        return true
    }
}

