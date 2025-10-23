//
//  SubscriptionType.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import Foundation

enum SubscriptionType: String, CaseIterable {
    case weekly
    // case yearly // Убрано - не используется
    
    var id: String {
        switch self {
        case .weekly: "week_899_3dtrial"
        // case .yearly: "year_8988" // Убрано - не используется
        }
    }
}
