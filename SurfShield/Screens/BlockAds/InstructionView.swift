//
//  EnableBlockerInstructionView.swift
//  SurfShield
//
//  Created by Артур Кулик on 04.10.2025.
//

import SwiftUI

struct InstructionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var scrollOffset: CGPoint = .zero
    @State private var timer: Timer?
    @State private var enabledItems: Set<String> = []
    
    var body: some View {
        ZStack {
            // Static gradient background
            StaticGradientBackground()
                .ignoresSafeArea()
            
            // Light dark gradient overlay
            LightDarkGradientOverlay()
            
            VStack(spacing: 16) {
                // 1. Главный заголовок
                VStack(spacing: 12) {
                    Text("Enable Extensions")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.tm.title)
                    
                    Text("To activate the blocker, you need to enable extensions in Safari settings")
                        .font(.subheadline)
                        .foregroundColor(.tm.subTitle)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 40)
                
                // Красивая инструкция
                VStack(spacing: 16) {
                    InstructionCardView(
                        icon: "settings",
                        text: "Open Settings"
                    )
                    
                    InstructionCardView(
                        icon: "applications",
                        text: "Open applications"
                    )
                    
                    InstructionCardView(
                        icon: "safari",
                        text: "Find Safari → Extensions"
                    )
                    
                    InstructionCardView(
                        icon: "Onboarding0AppIcon",
                        text: "Enable SurfShield Extensions"
                    )
                }
                .padding(.horizontal, 19)
                .padding(.top, 20)
                // 4. Список расширений
                SettingsFormView(settingsItems: settingsItems, enabledItems: enabledItems)
                    .offset(y: -30)
            }
        }
        
        .onAppear {
            startTextChangeTimer()
        }
        .onDisappear {
            stopTextChangeTimer()
        }
    }
    
    private func startTextChangeTimer() {
        let items = settingsItems
        var currentIndex = 0
        var isResetting = false
        var isPaused = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
            if !isResetting && !isPaused && currentIndex < items.count {
                // Включаем элементы по очереди
                let item = items[currentIndex]
                withAnimation(.easeInOut(duration: 0.3)) {
                    enabledItems.insert(item.id)
                }
                currentIndex += 1
                
                // Если все элементы включены, делаем паузу на секунду
                if currentIndex >= items.count {
                    isPaused = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        isPaused = false
                        isResetting = true
                        currentIndex = 0
                    }
                }
            } else if isResetting && !isPaused {
                // Сбрасываем все элементы с анимацией
                withAnimation(.easeInOut(duration: 0.4)) {
                    enabledItems.removeAll()
                }
                isResetting = false
                currentIndex = 0
            }
        }
    }
    
    private func stopTextChangeTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func createGradientImage() -> UIImage {
        let size = CGSize(width: 90, height: 65) // Ширина больше высоты для растягивания
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // Сначала заливаем весь фон базовым цветом
            cgContext.setFillColor(UIColor(Color.tm.calmAccent).cgColor)
            cgContext.fill(CGRect(origin: .zero, size: size))
            
            // Создаем градиент
            let colors = [
                UIColor(Color.tm.calmAccentSecondary).cgColor,
                UIColor(Color.tm.calmAccent).cgColor
            ]
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0.2, 1])!
            
            // Центр градиента - внизу по центру
            let center = CGPoint(x: size.width / 2, y: size.height)
            let radius: CGFloat = 45 //size.width * 0.6 // Радиус почти на всю ширину
            
            // Рисуем радиальный градиент поверх фона
            cgContext.drawRadialGradient(
                gradient,
                startCenter: center,
                startRadius: 20,
                endCenter: center,
                endRadius: radius,
                options: []
            )
        }
    }
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

// MARK: - Settings Item Model
struct SettingsItem {
    let id: String
    let title: String
}


// MARK: - Background Components
struct StaticGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                .tm.container,
                .tm.container.opacity(0.95),
                .tm.container.opacity(0.7),
                .tm.container
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct LightDarkGradientOverlay: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.clear,
                Color.black.opacity(0.1),
                Color.black.opacity(0.2),
                Color.black.opacity(0.15)
            ],
            startPoint: .topTrailing,
            endPoint: .bottomLeading
        )
        .ignoresSafeArea()
    }
}

// MARK: - Settings Form Component
struct SettingsFormView: View {
    let settingsItems: [SettingsItem]
    let enabledItems: Set<String>
    
    var body: some View {
        Form(content: {
            ForEach(Array(settingsItems.enumerated()), id: \.element.id) { index, item in
                SettingsRowView(item: item, enabledItems: enabledItems)
                    .listRowBackground(Color.white.opacity(0.019))
            }
        })
        .scrollDisabled(true)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Settings Row Component
struct SettingsRowView: View {
    let item: SettingsItem
    let enabledItems: Set<String>
    
    var body: some View {
        HStack {
            Label(title: {
                Text(item.title)
                    .foregroundColor(.tm.title)
            }, icon: {
                Image("Onboarding0AppIcon")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            })
            
            Spacer()
            
            HStack(spacing: 4) {
                Text(enabledItems.contains(item.id) ? "On" : "Off")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.tm.subTitle)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.tm.subTitle.opacity(0.6))
            }
        }
    }
}

// MARK: - Instruction Card Component
struct InstructionCardView: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.tm.accentSecondary)
            
            Text(text)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.tm.title)
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.tm.container)
        )
    }
}

#Preview {
    InstructionView()
}
