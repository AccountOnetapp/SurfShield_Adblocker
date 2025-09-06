//
//  OnboardingView.swift
//  SufrShield
//
//  Created by Артур Кулик on 06.09.2025.
//

import SwiftUI

// MARK: - Onboarding Data Model
struct OnboardingPage {
    let id: Int
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
    let animationType: AnimationType
}

enum AnimationType {
    case shield, browser, statistics, settings
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @State private var currentPage = 0
    @State private var isAnimating = false
    @State private var showContent = false
    @Environment(\.dismiss) private var dismiss
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            title: "Welcome to SufrShield",
            subtitle: "Your reliable internet guardian",
            description: "Block ads, trackers, and malicious websites with a single tap",
            icon: "shield.fill",
            color: .tm.accent,
            animationType: .shield
        ),
        OnboardingPage(
            id: 1,
            title: "Secure Browser",
            subtitle: "Surf without restrictions",
            description: "Built-in browser with advanced protection and resource monitoring",
            icon: "safari.fill",
            color: .tm.accentSecondary,
            animationType: .browser
        ),
        OnboardingPage(
            id: 2,
            title: "Detailed Statistics",
            subtitle: "Control your security",
            description: "Track blocked resources and analyze your traffic",
            icon: "chart.bar.fill",
            color: .tm.accentTertiary,
            animationType: .statistics
        ),
        OnboardingPage(
            id: 3,
            title: "Ready to Use",
            subtitle: "Start protecting your internet",
            description: "Configure blocking settings and enjoy safe browsing",
            icon: "checkmark.circle.fill",
            color: .tm.success,
            animationType: .settings
        )
    ]
    
    var body: some View {
        ZStack {
            // Анимированный фон с цветом текущей страницы
            animatedBackground
                .ignoresSafeArea()
            
            // Частицы на фоне
            ParticlesView()
                .opacity(0.3)
            
            VStack(spacing: 0) {
                // Контент страницы
                pageContent
                
                // Индикаторы страниц
                pageIndicators
                
                // Кнопки навигации
                navigationButtons
            }
        }
        .onAppear {
            startInitialAnimation()
        }
    }
    
    // MARK: - Animated Background
    @ViewBuilder
    private var animatedBackground: some View {
        ZStack {
            // Базовый градиент
            LinearGradient(
                colors: [
                    pages[currentPage].color.opacity(0.8),
                    pages[currentPage].color.opacity(0.4),
                    .tm.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .animation(.easeInOut(duration: 0.8), value: currentPage)
            
            // Дополнительные слои для глубины
            Circle()
                .fill(pages[currentPage].color.opacity(0.1))
                .frame(width: 300, height: 300)
                .offset(x: -100, y: -200)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: isAnimating)
            
            Circle()
                .fill(pages[currentPage].color.opacity(0.05))
                .frame(width: 200, height: 200)
                .offset(x: 150, y: 300)
                .scaleEffect(isAnimating ? 0.8 : 1.2)
                .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true).delay(0.5), value: isAnimating)
        }
    }
    
    // MARK: - Page Content
    @ViewBuilder
    private var pageContent: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Анимированная иконка
            animatedIcon
            
            // Текстовый контент
            VStack(spacing: 16) {
                Text(pages[currentPage].title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.tm.title)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                Text(pages[currentPage].subtitle)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(.tm.subTitle)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
                
                Text(pages[currentPage].description)
                    .font(.body)
                    .foregroundStyle(.tm.subTitle.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : 20)
            }
            .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
            
            
            Spacer()
        }
    }
    
    // MARK: - Animated Icon
    @ViewBuilder
    private var animatedIcon: some View {
        ZStack {
            // Фоновое свечение с градиентом
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            pages[currentPage].color.opacity(0.3),
                            pages[currentPage].color.opacity(0.1),
                            .clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(isAnimating ? 1.3 : 1.0)
                .opacity(isAnimating ? 0.4 : 0.7)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
            
            // Дополнительные кольца
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                pages[currentPage].color.opacity(0.6),
                                pages[currentPage].color.opacity(0.2),
                                .white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 120 + CGFloat(index * 20), height: 120 + CGFloat(index * 20))
                    .scaleEffect(isAnimating ? 1.1 : 0.9)
                    .opacity(isAnimating ? 0.3 : 0.6)
                    .animation(
                        .easeInOut(duration: 2.5 + Double(index) * 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.3),
                        value: isAnimating
                    )
            }
            
            // Основная иконка с градиентом
            Image(systemName: pages[currentPage].icon)
                .font(.system(size: 60, weight: .medium))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            pages[currentPage].color,
                            .white.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(isAnimating ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                .overlay {
                    // Дополнительные анимации в зависимости от типа
                    animationOverlay
                }
        }
        .opacity(showContent ? 1 : 0)
        .scaleEffect(showContent ? 1 : 0.8)
        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showContent)
    }
    
    // MARK: - Animation Overlay
    @ViewBuilder
    private var animationOverlay: some View {
        switch pages[currentPage].animationType {
        case .shield:
            ShieldAnimation()
        case .browser:
            BrowserAnimation()
        case .statistics:
            StatisticsAnimation()
        case .settings:
            SettingsAnimation()
        }
    }
    
    // MARK: - Page Indicators
    @ViewBuilder
    private var pageIndicators: some View {
        HStack(spacing: 12) {
            ForEach(0..<pages.count, id: \.self) { index in
                Circle()
                    .fill(
                        index == currentPage 
                        ? LinearGradient(
                            colors: [
                                pages[index].color,
                                pages[index].color.opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [
                                .tm.subTitle.opacity(0.3),
                                .white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: index == currentPage ? 12 : 8, height: index == currentPage ? 12 : 8)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: currentPage)
            }
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Navigation Buttons
    @ViewBuilder
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentPage > 0 {
                Button("Back") {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentPage -= 1
                        resetAnimation()
                    }
                }
                .buttonStyle(SecondaryButtonStyle())
            }
            
            Spacer()
            
            Button(currentPage == pages.count - 1 ? "Get Started" : "Next") {
                if currentPage == pages.count - 1 {
                    completeOnboarding()
                } else {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentPage += 1
                        resetAnimation()
                    }
                }
            }
            .buttonStyle(PrimaryButtonStyle(color: pages[currentPage].color))
        }
        .padding(.horizontal, 32)
        .padding(.bottom, 50)
    }
    
    // MARK: - Animation Methods
    private func startInitialAnimation() {
        withAnimation(.easeOut(duration: 0.8)) {
            showContent = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isAnimating = true
        }
    }
    
    private func resetAnimation() {
        showContent = false
        isAnimating = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.6)) {
                showContent = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isAnimating = true
            }
        }
    }
    
    private func completeOnboarding() {
        // Сохраняем, что онбординг пройден
        UserDefaultsService.shared.save(true, forKey: .onboardingCompleted)
        
        withAnimation(.easeInOut(duration: 0.5)) {
            dismiss()
        }
    }
}

// MARK: - Animation Components

struct ShieldAnimation: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            ForEach(0..<3) { index in
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                .tm.accent.opacity(0.6),
                                .tm.accent.opacity(0.2),
                                .white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 120 + CGFloat(index * 20), height: 120 + CGFloat(index * 20))
                    .scaleEffect(scale)
                    .opacity(1.0 - Double(index) * 0.3)
                    .rotationEffect(.degrees(rotation))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
        }
    }
}

struct BrowserAnimation: View {
    @State private var progress: CGFloat = 0
    @State private var opacity: Double = 0.5
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(0..<3) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                .tm.accentSecondary.opacity(opacity),
                                .white.opacity(opacity * 0.7)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 80 - CGFloat(index * 10), height: 4)
                    .scaleEffect(x: progress, y: 1)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(Double(index) * 0.2), value: progress)
            }
        }
        .onAppear {
            progress = 1.0
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}

struct StatisticsAnimation: View {
    @State private var bars: [CGFloat] = [0.3, 0.7, 0.5, 0.9, 0.4, 0.8]
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(0..<bars.count, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [
                                .tm.accentTertiary,
                                .white.opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 8, height: bars[index] * 40)
                    .scaleEffect(y: animationOffset)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(Double(index) * 0.1), value: animationOffset)
            }
        }
        .onAppear {
            animationOffset = 1.0
        }
    }
}

struct SettingsAnimation: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            ForEach(0..<6) { index in
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                .tm.success.opacity(0.8),
                                .white.opacity(0.6)
                            ],
                            center: .center,
                            startRadius: 1,
                            endRadius: 2
                        )
                    )
                    .frame(width: 4, height: 4)
                    .offset(
                        x: cos(Double(index) * .pi / 3 + rotation) * 30,
                        y: sin(Double(index) * .pi / 3 + rotation) * 30
                    )
                    .scaleEffect(scale)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                rotation = 2 * .pi
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.2
            }
        }
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            colors: [
                                color,
                                color.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: color.opacity(0.4), radius: 12, x: 0, y: 6)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.tm.subTitle)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(.tm.container)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(.tm.subTitle.opacity(0.3), lineWidth: 1)
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    OnboardingView()
}
