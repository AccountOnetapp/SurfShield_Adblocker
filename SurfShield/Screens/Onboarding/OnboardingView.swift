//
//  OnboardingView.swift
//  SurfShield
//
//  Created by Артур Кулик on 09.09.2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentScreen = 0
    @State private var isAnimating = false
    
    @EnvironmentObject var appState: AppState
    
    private let totalScreens = 4
    
    
    
    var body: some View {
        content
    }
    
    var content: some View {
        VStack(spacing: 0) {
            // Контент экранов
            TabView(selection: $currentScreen) {
                FirstOnboardingScreen()
                    .tag(0)
                    .id(0)
                    .padding(.bottom, 44)
                
                Group {
                    OnboardingScreen(
                        title: "Protection",
                        imageResource: .onboarding1,
                        attributedText: "SufrShield protects personal data and stops intrusive ads and tracking"
                            .attributed(
                                phrases: ["SufrShield", "ads and tracking"],
                                color: .tm.calmAccent
                            )
                    )
                    .tag(1)
                    .id(1)
                    
                    OnboardingScreen(
                        title: "Speed",
                        imageResource: .onboarding2,
                        attributedText: "Download faster, play, and go online without threats and annoying banners"
                            .attributed(
                                phrases: ["Download", "annoying banners"],
                                color: .tm.calmAccent
                            )
                    )
                    .tag(2)
                    .id(2)
                    
                    OnboardingScreen(
                        title: "Freedom",
                        imageResource: .onboarding3,
                        attributedText: "No ads, no trackers — just freedom, comfort, and fast website loading"
                            .attributed(
                                phrases: ["No ads, no trackers", "fast website"],
                                color: .tm.calmAccent
                            )
                    )
                    .tag(3)
                    .id(3)
                }
                .padding(.bottom, .extraLarge)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            .animation(.easeInOut(duration: 0.3), value: currentScreen)
            
            // Кнопка Continue
            
            MainButton(title: "Continue") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if currentScreen < totalScreens - 1 {
                        currentScreen += 1
                    } else {
                        appState.onboardingCompleted()
                    }
                }
            }
        }
        .padding(.bottom, 14)
        .padding(.horizontal, .medium)
        .background(
            RadialGradient(
                gradient: Gradient(colors: [Color.tm.backgroundSecondary, Color.tm.background]),
                center: UnitPoint(x: 1.0, y: 1.0),
                startRadius: 0,
                endRadius: 700
            )
            .ignoresSafeArea()
        )
    }


}



// MARK: - Первый экран
struct FirstOnboardingScreen: View {
    var body: some View {
        
        VStack(spacing: .zero) {
            // Заголовок
            Text("How to\nEnable Blocking".attributed(phrases: ["Enable Blocking"], color: .tm.calmAccent, font: .sfProText(size: 36, weight: .bold)))
                .font(.system(size: 36, weight: .bold, design: .default))
                .foregroundColor(.tm.title)
                .multilineTextAlignment(.center)
                .padding(.vertical, 42)
            // Подзаголовок
            Text("Before we can start, SurfShield extensions need to be enabled in Safari settings")
                .font(.sfProText(size: 16, weight: .regular))
                .foregroundColor(.tm.subTitle)
                .multilineTextAlignment(.center)
       
            Spacer(minLength: .zero)
        // Видео (заглушка)
            RoundedRectangle(cornerRadius: 16)
                .fill(.clear)
                .frame(width: 260, height: 230)
                .overlay(alignment: .bottomTrailing) {
                    Image(.onboarding0Safari)
                        .resizable()
                        .frame(width: 144, height: 144)
                }
                .overlay(alignment: .topLeading) {
                    Image(.onboarding0AppIcon)
                        .resizable()
                        .frame(width: 144, height: 144)
                        .shadow(color: .black.opacity(0.4), radius: 60, x: .zero, y: 30)
                }
    
            Spacer(minLength: .zero)
        
        // Текст
        Text("Settings → Apps → Safari → Extensions → Content Blockers and turn on the SufrShield switches")
            .font(.system(size: 16, weight: .regular, design: .default))
            .lineSpacing(3.5)
            .foregroundStyle(.tm.subTitle)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 22)
        }
    }
}

// MARK: - Переиспользуемый компонент для экранов 2-4
struct OnboardingScreen: View {
    let title: String
    let imageResource: ImageResource
    let attributedText: AttributedString
    
    var body: some View {
        VStack(spacing: .zero) {
            Spacer()
            
            VStack(spacing: .zero) {
                // Заголовок
                Text(title)
                    .font(.sfProText(size: 36, weight: .bold))
                    .foregroundColor(.tm.title)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 42)
                
//                Spacer(minLength: .zero)
                // Изображение
                Image(imageResource)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 342)
                    .padding(.top, .large)
                Spacer(minLength: .zero)
                // Текст с атрибутами
                Text(attributedText)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .medium)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
