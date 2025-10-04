//
//  EnableBlockerInstructionView.swift
//  SurfShield
//
//  Created by Артур Кулик on 04.10.2025.
//

import SwiftUI

struct EnableBlockerInstructionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGPoint = .zero
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 0) {
            // Заголовок (фиксированный)
            Text("Тестовый Sheet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.tm.title)
                .padding(.top, 20)
                .padding(.bottom, 16)
            
            ScrollView {
                    // Группированный список
                    VStack(spacing: 0) {
                        ForEach(Array(settingsItems.enumerated()), id: \.element.id) { index, item in
                            SettingsRowView(item: item, isLast: index == settingsItems.count - 1)
                        }
                    }
                    .background(Color.white)
                    .padding(.horizontal, 16)
//                .scrollToOffset(contentOffset: $scrollOffset)
            }
            .frame(maxWidth: .infinity)
            // Кнопка закрытия (фиксированная)
            Button("Закрыть") {
                scrollOffset = .init(x: 0, y: 50)
            }
            .buttonStyle(.borderedProminent)
            .tint(.tm.accentSecondary)
            .padding(.horizontal, 40)
            .padding(.vertical, 16)
        }
        .background(.tm.container)
        .onAppear {
            startAutoScroll()
        }
    }
    
    private func startAutoScroll() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            withAnimation(.linear(duration: 0.1)) {
                scrollOffset.y += 3
            }
        }
    }
    
    private func stopAutoScroll() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Settings Data
    private var settingsItems: [SettingsItem] {
        [
            SettingsItem(
                id: "adblock",
                title: "SurfShield - AdBlock"
            ),
            SettingsItem(
                id: "privacy",
                title: "SurfShield - Advanced"
            ),
            SettingsItem(
                id: "trackers",
                title: "SurfShield - Banners"
            ),
            SettingsItem(
                id: "popups",
                title: "SurfShield - Basic"
            ),
            SettingsItem(
                id: "malware",
                title: "SurfShield - Privacy"
            ),
            SettingsItem(
                id: "advanced",
                title: "SurfShield - Security"
            ),
            SettingsItem(
                id: "premium",
                title: "SurfShield - Trackers"
            )
        ]
    }
}

// MARK: - Settings Item Model
struct SettingsItem {
    let id: String
    let title: String
}

// MARK: - Settings Row View
struct SettingsRowView: View {
    let item: SettingsItem
    let isLast: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: .zero) {
                // Иконка приложения
                Image("Onboarding0AppIcon")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 12)
                // Контент
                Text(item.title)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("Disable.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
                    .padding(.horizontal, 4)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
                    .opacity(0.8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.clear)
            
            // Разделитель (только если не последний элемент)
            if !isLast {
                Divider()
//                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 0.5)
                    .padding(.leading, 52) // Отступ под иконку
            }
        }
    }
}

#Preview {
    EnableBlockerInstructionView()
}
