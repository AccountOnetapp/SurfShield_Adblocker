//
//  Screen.swift
//  Lumio
//
//  Created by Артур Кулик on 22.08.2025.
//

import Foundation

enum Screen: Hashable {
    
    static func == (lhs: Screen, rhs: Screen) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
    }
    
}

