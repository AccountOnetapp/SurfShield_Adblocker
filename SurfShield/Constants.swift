//
//  Constants.swift
//  SufrShield
//
//  Created by Артур Кулик on 25.08.2025.
//

import Foundation


enum Constants {
    static var adblockGroupId = "group.surfshield.app.adblocker"
//    static var adblockGroupId = "com.surfshield.adblocker.group"
    
    // MARK: - URLs
    static let privacyPolicyURL = "https://docs.google.com/document/d/1mFiYDladzxKrQEaHtCd88oA5Ialv8yqGEjjJAswx13o/edit?tab=t.0"
    static let termsOfUseURL = "https://docs.google.com/document/d/1SfefoNqYwkAAIynePGWyMz53rc7ERZOKbQ0dUwMT154/edit?tab=t.0"
    
    enum BlockExtenesionBundleIds: String, CaseIterable {
        case adblocker = "com.surfshield.adblocket.ex1"
        case privacy = "com.surfshield.adblocket.ex2"
        case banners = "com.surfshield.adblocket.ex3"
        case trackers = "com.surfshield.adblocket.ex4"
        case advanced = "com.surfshield.adblocket.ex5"
        case secure = "com.surfshield.adblocket.ex6"
        case basic = "com.surfshield.adblocket.ex7"
        
        static var all: [String] {
            BlockExtenesionBundleIds.allCases.map { $0.rawValue }
        }
    }
}
