//
//  String+Extensions.swift
//  SurfShield
//
//  Created by Артур Кулик on 10.09.2025.
//

import Foundation
import SwiftUI

extension String {
    /// Создает AttributedString с выделенными фразами
    /// - Parameters:
    ///   - phrases: Массив фраз для выделения
    ///   - color: Цвет для выделенных фраз
    ///   - font: Шрифт для текста (по умолчанию SF Pro Text 24pt semibold)
    ///   - baseColor: Базовый цвет текста (по умолчанию tm.title)
    /// - Returns: AttributedString с выделенными фразами
    public func attributed(
        phrases: [String],
        color: Color,
        font: Font = .sfProText(size: 24, weight: .semibold),
        baseColor: Color = Color.tm.title
    ) -> AttributedString {
        var attributedString = AttributedString(self)
        
        // Настройки базового шрифта
        attributedString.font = font
        attributedString.foregroundColor = UIColor(baseColor)
        
        // Выделяем указанные фразы
        for phrase in phrases {
            if let range = attributedString.range(of: phrase) {
                attributedString[range].foregroundColor = UIColor(color)
            }
        }
        
        return attributedString
    }
}
