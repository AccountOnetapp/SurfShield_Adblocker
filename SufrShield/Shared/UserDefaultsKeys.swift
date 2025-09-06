//
//  UserDefaultsKeys.swift
//  SufrShield
//
//  Created by Артур Кулик on 04.09.2025.
//

import Foundation

/// Enum для ключей UserDefaults
enum UserDefaultsKeys: String, CaseIterable {
    case resourceAnalysis = "resource_analysis"
    case blockedResources = "blocked_resources"
    case loadedResources = "loaded_resources"
    case pageResources = "page_resources"
    case trafficStatistics = "traffic_statistics"
    case adBlockRules = "ad_block_rules"
    case userSettings = "user_settings"
    case adBlockerEnabled = "adBlockerEnabled"
    case webViewBlockedStatistics = "webViewBlockedStatistics"
    
    var key: String {
        return self.rawValue
    }
}
