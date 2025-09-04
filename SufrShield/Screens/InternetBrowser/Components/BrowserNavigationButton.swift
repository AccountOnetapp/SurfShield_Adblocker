//
//  BrowserNavigationButton.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI

enum BrowserNavigationButtonType {
    case back
    case forward
    case refresh
    case share
    
    var iconName: String {
        switch self {
        case .back:
            return "chevron.left"
        case .forward:
            return "chevron.right"
        case .refresh:
            return "arrow.clockwise"
        case .share:
            return "square.and.arrow.up"
        }
    }
    
    var isEnabled: Bool {
        switch self {
        case .back, .forward:
            return false // Будет передаваться извне
        case .refresh, .share:
            return true
        }
    }
}

struct BrowserNavigationButton: View {
    let type: BrowserNavigationButtonType
    let action: () -> Void
    let isEnabled: Bool
    
    init(_ type: BrowserNavigationButtonType, isEnabled: Bool = true, action: @escaping () -> Void) {
        self.type = type
        self.isEnabled = isEnabled
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: type.iconName)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isEnabled ? .primary : .secondary)
        }
        .disabled(!isEnabled)
    }
}
