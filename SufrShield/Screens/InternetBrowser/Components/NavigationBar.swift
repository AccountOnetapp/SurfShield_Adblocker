//
//  NavigationBar.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI

struct NavigationBar: View {
    let canGoBack: Bool
    let canGoForward: Bool
    let onBack: () -> Void
    let onForward: () -> Void
    let onHome: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            // Кнопка "Назад"
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(canGoBack ? .primary : .secondary)
            }
            .disabled(!canGoBack)
            
            // Кнопка "Вперед"
            Button(action: onForward) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(canGoForward ? .primary : .secondary)
            }
            .disabled(!canGoForward)
            
            Spacer()
            
            // Кнопка "Домой"
            Button(action: onHome) {
                Image(systemName: "house")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            // Кнопка "Поделиться"
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
    }
}

#Preview {
    NavigationBar(
        canGoBack: true,
        canGoForward: false,
        onBack: { print("Back") },
        onForward: { print("Forward") },
        onHome: { print("Home") },
        onShare: { print("Share") }
    )
}
