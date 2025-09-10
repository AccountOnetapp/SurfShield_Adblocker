//
//  Fonts.swift
//  SurfShield
//
//  Created by Артур Кулик on 09.09.2025.
//

import SwiftUI

extension Font {
    // SF Pro Text шрифты
    static func sfProTextRegular(size: CGFloat) -> Font {
        return .custom("SFProText-Regular", size: size)
    }
    
    static func sfProTextMedium(size: CGFloat) -> Font {
        return .custom("SFProText-Medium", size: size)
    }
    
    static func sfProTextSemibold(size: CGFloat) -> Font {
        return .custom("SFProText-Semibold", size: size)
    }
    
    static func sfProTextBold(size: CGFloat) -> Font {
        return .custom("SFProText-Bold", size: size)
    }
    
    // SF Pro Rounded шрифты
    static func sfProRoundedBold(size: CGFloat) -> Font {
        return .custom("SFProRounded-Bold", size: size)
    }
    
    // Удобные методы с весами для SF Pro Text
    public static func sfProText(size: CGFloat, weight: SFProTextWeight = .regular) -> Font {
        switch weight {
        case .regular:
            return .sfProTextRegular(size: size)
        case .medium:
            return .sfProTextMedium(size: size)
        case .semibold:
            return .sfProTextSemibold(size: size)
        case .bold:
            return .sfProTextBold(size: size)
        }
    }
    
    // Удобные методы с весами для SF Pro Rounded
    public static func sfProRounded(size: CGFloat, weight: SFProRoundedWeight = .bold) -> Font {
        switch weight {
        case .bold:
            return .sfProRoundedBold(size: size)
        }
    }
}

// Enum для весов шрифта SF Pro Text
public enum SFProTextWeight {
    case regular
    case medium
    case semibold
    case bold
}

// Enum для весов шрифта SF Pro Rounded
public enum SFProRoundedWeight {
    case bold
}
