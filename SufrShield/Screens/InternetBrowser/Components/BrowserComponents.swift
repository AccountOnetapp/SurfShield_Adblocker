//
//  BrowserComponents.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI

// MARK: - Общие компоненты для браузера

/// Контейнер для всех компонентов браузера
struct BrowserComponents {
    // Этот файл служит как индекс для всех компонентов браузера
    // Здесь можно добавить общие стили, константы и утилиты
}

// MARK: - Стили и константы

extension BrowserComponents {
    struct Style {
        static let cornerRadius: CGFloat = 8
        static let buttonSize: CGFloat = 36
        static let iconSize: CGFloat = 18
        static let padding: CGFloat = 16
    }
    
    struct Colors {
        static let primary = Color.blue
        static let secondary = Color.secondary
        static let background = Color(.systemBackground)
        static let overlay = Color.black.opacity(0.1)
    }
}
