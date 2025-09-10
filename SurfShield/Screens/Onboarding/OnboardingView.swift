//
//  OnboardingView.swift
//  SurfShield
//
//  Created by Артур Кулик on 09.09.2025.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentScreen = 1
    @State private var isAnimating = false
    
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
            
            // Кнопка Continue
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    if currentScreen < totalScreens - 1 {
                        currentScreen += 1
                    } else {
                        // Завершение онбординга
                        // Здесь можно добавить логику завершения
                    }
                }
            }) {
                Text("Continue")
                    .font(.sfProText(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        Image(uiImage: createGradientImage())
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                        //                              .frame(width: 280)
                    )
                    .clipShape(.rect(cornerRadius: 16))
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
    
    
    // Функция для создания градиента через CALayer
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

// MARK: - Первый экран
struct FirstOnboardingScreen: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                // Заголовок
                Text("Добро пожаловать в SurfShield")
                    .font(.system(size: 36, weight: .bold, design: .default))
                    .foregroundColor(.tm.title)
                    .multilineTextAlignment(.center)
                
                // Подзаголовок
                Text("Защитите себя от рекламы и трекеров")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.tm.subTitle)
                    .multilineTextAlignment(.center)
            }
            
            // Видео (заглушка)
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.tm.container)
                .frame(height: 200)
                .overlay(
                    VStack(spacing: 12) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 48))
                            .foregroundColor(.tm.accent)
                        
                        Text("Видео-инструкция")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.tm.title)
                    }
                )
                .padding(.horizontal, 24)
            
            // Текст
            Text("Следуйте инструкциям в видео, чтобы настроить блокировщик рекламы в Safari")
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundColor(.tm.subTitle)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
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
            
            VStack(spacing: 24) {
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
                    .scaledToFill()
                    .frame(height: 342)
                Spacer(minLength: .zero)
                // Текст с атрибутами
                Text(attributedText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .medium)
            }
        }
    }
}

#Preview {
    OnboardingView()
}
