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
        
        print("\n🚀 === ИНИЦИАЛИЗАЦИЯ APPHUD ===\n")
        print("DEBUG: IDFV: \(idfv ?? "nil")")
        print("DEBUG: API Key: \(Constants.apphudApiKey)")
        
        // Инициализация AppHud с IDF
        Apphud.start(apiKey: Constants.apphudApiKey)
//        Apphud.startManually(apiKey: Constants.apphudApiKey, deviceID: idfv)
        
        // Проверяем инициализацию
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let userID = Apphud.userID()
            print("DEBUG: AppHud User ID после инициализации: \(userID)")
            
            // Проверяем статус подписки
            let hasActive = Apphud.hasActiveSubscription()
            print("DEBUG: hasActiveSubscription после инициализации: \(hasActive)")
        }
        
        print("\n🚀 === КОНЕЦ ИНИЦИАЛИЗАЦИИ ===\n")
        
        return true
    }
}

