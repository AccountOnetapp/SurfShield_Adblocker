//
//  SplashScreenView.swift
//  SurfShield
//
//  Created by Артур Кулик on 11.10.2025.
//

import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var appState: AppState
    @State private var isAnimating = false
    @State private var pulseAnimation = false
    
    var body: some View {
        ZStack {
            // Фоновое изображение или градиент
            if let _ = UIImage(named: "LaunchScreenBackground") {
                Image("LaunchScreenBackground")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                // Градиентный фон если нет фонового изображения
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.1, green: 0.1, blue: 0.2),
                        Color.black
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Логотип приложения
                if let _ = UIImage(named: "LaunchIcon") {
                    Image("LaunchIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .cornerRadius(26)
                        .shadow(color: .white.opacity(0.3), radius: pulseAnimation ? 20 : 10)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.8), value: isAnimating)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                } else {
                    // Fallback на текст
                    Text("SurfShield")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .blue.opacity(0.5), radius: 10)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeOut(duration: 0.8), value: isAnimating)
                }
                
                Spacer()
                
                // Индикатор загрузки
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.2)
                    
                    Text("Загрузка...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.6).delay(0.3), value: isAnimating)
                
                Spacer()
                    .frame(height: 60)
            }
            .padding()
        }
        .onAppear {
            isAnimating = true
            pulseAnimation = true
        }
    }
}

#Preview {
    SplashScreenView()
        .environmentObject(AppState())
}

