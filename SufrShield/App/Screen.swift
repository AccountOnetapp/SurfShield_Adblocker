//
//  Screen.swift
//  Lumio
//
//  Created by Артур Кулик on 22.08.2025.
//

import Foundation

enum Screen: Hashable {
    case calendar
    case role
    
    static func == (lhs: Screen, rhs: Screen) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case .calendar:
            hasher.combine("calendar")
        case .role:
            hasher.combine("role")
        }
    }
}

