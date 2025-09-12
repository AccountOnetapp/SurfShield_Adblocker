//
//  Constants.swift
//  SufrShield
//
//  Created by Артур Кулик on 25.08.2025.
//

import Foundation


enum Constants {
    static var adblockGroupId = "com.surfshield.adblocker.group"
    
    // MARK: - URLs
    static let privacyPolicyURL = "https://docs.google.com/document/d/1mFiYDladzxKrQEaHtCd88oA5Ialv8yqGEjjJAswx13o/edit?tab=t.0"
    static let termsOfUseURL = "https://docs.google.com/document/d/1SfefoNqYwkAAIynePGWyMz53rc7ERZOKbQ0dUwMT154/edit?tab=t.0"
    
    enum BlockExtenesionBundleIds: String, CaseIterable {
        case adblocker = "com.surfshield.adblocker.extension.adblocker"
        case privacy = "com.surfshield.adblocker.extension.privacy"
        case banners = "com.surfshield.adblocker.extension.banners"
        case trackers = "com.surfshield.adblocker.extensions.trackers"
        case advanced = "com.surfshield.adblocker.extension.advanced"
        case secure = "com.surfshield.adblocker.extension.secure"
        case basic = "com.surfshield.adblocker.extension.basic"
        
        static var all: [String] {
            BlockExtenesionBundleIds.allCases.map { $0.rawValue }
        }
    }
}
