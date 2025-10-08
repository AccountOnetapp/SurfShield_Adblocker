//
//  SurfShieldApp.swift
//  SurfShield
//
//  Created by Артур Кулик on 23.08.2025.
//

import SwiftUI

@main
struct SurfShieldApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .preferredColorScheme(.dark)
        }
    }
}

