//
//  Colors.swift
//  Lumio
//
//  Created by Артур Кулик on 22.08.2025.
//

import SwiftUI

public enum ThemeColors: String {
    case accent = "Accent"
    case accentSecondary = "AccentSecondary"
    case accentTertiary = "AccentTertiary"
    case title = "Title"
    case subTitle = "Subtitle"
    case subTitleSecondary = "SubtitleSecondary"
    case background = "Background"
    case backgroundSecondary = "BackgroundSecondary"
    case container = "Container"
    case error = "Error"
    case success = "Success"
    case calm = "Calm"
    case calmSecondary = "CalmSecondary"
    case calmAccent = "CalmAccent"
    case calmAccentSecondary = "CalmAccentSecondary"
    
    // Тут будет дополнительное вычисляемое свойство для определения выбора темы из экрана настроек
    var color: Color {
        let name = self.rawValue
        return Color(name)
    }
}

public struct Colors {
    public var accent: Color { ThemeColors.accent.color }
    public var accentSecondary: Color { ThemeColors.accentSecondary.color }
    public var accentTertiary: Color { ThemeColors.accentTertiary.color }
    public var background: Color { ThemeColors.background.color }
    public var backgroundSecondary: Color { ThemeColors.backgroundSecondary.color }
    public var container: Color { ThemeColors.container.color }
    public var error: Color { ThemeColors.error.color }
    public var success: Color { ThemeColors.success.color }
    public var title: Color { ThemeColors.title.color }
    public var subTitle: Color { ThemeColors.subTitle.color }
    public var subTitleSecondary: Color { ThemeColors.subTitleSecondary.color }
    public var calm: Color { ThemeColors.calm.color }
    public var calmSecondary: Color { ThemeColors.calmSecondary.color }
    public var calmAccent: Color { ThemeColors.calmAccent.color }
    public var calmAccentSecondary: Color { ThemeColors.calmAccentSecondary.color }
}


// Расширение для ShapeStyle
extension ShapeStyle where Self == Color {
    static var tm: Colors {
        Colors()
    }
}

// Расширение для Color
extension Color {
    public static var tm: Colors { Colors() }
    
    init(color: ThemeColors) {
        self = color.color
    }
}

// Расширение для использования в .foregroundStyle
extension ShapeStyle where Self == Color {
    static func fromColors(_ colors: ThemeColors) -> Self {
        return colors.color
    }
}
