//
//  Constants.swift
//  SufrShield
//
//  Created by Артур Кулик on 25.08.2025.
//

import Foundation


enum Constants {
    static var adblockGroupId = "group.surfshield.app.adblocker"
//    static var adblockGroupId = "group.surfshield.adblocker.group-group"
    
    // MARK: - URLs
    static let privacyPolicyURL = "https://docs.google.com/document/d/1mFiYDladzxKrQEaHtCd88oA5Ialv8yqGEjjJAswx13o/edit?tab=t.0"
    static let termsOfUseURL = "https://docs.google.com/document/d/1SfefoNqYwkAAIynePGWyMz53rc7ERZOKbQ0dUwMT154/edit?tab=t.0"
    static let appStoreLink = "https://itunes.apple.com/app/id6752290793?action=write-review"
    static let apphudApiKey = "app_E1p1cR6AjnHtF4ubgZZRcpg12vaKdu"
    
    enum BlockExtenesionBundleIds: String, CaseIterable {
        case adblocker = "com.surfshield.adblocket.adblockerdev"
        case privacy = "com.surfshield.adblocket.privacydev"
        case banners = "com.surfshield.adblocket.bannersdev"
        case trackers = "com.surfshield.adblocket.trackersdev"
        case advanced = "com.surfshield.adblocket.advanceddev"
        case secure = "com.surfshield.adblocket.securedev"
        case basic = "com.surfshield.adblocket.basicdev"
        
        static var all: [String] {
            BlockExtenesionBundleIds.allCases.map { $0.rawValue }
        }
    }
}
