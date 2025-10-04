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
            // Simple header
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
            .padding(.top, 20)
            // Simple Form
            Form(content: {
                ForEach(Array(settingsItems.enumerated()), id: \.element.id) { index, item in
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
                            Text("Disable.")
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.tm.subTitle)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.tm.subTitle.opacity(0.6))
                        }
                    }
                }
            })
            .scrollDisabled(true)
            .scrollContentBackground(.hidden)
            .cornerRadius(12)
            // Simple action button
            Button(action: {
                // Open Safari settings
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }) {
                HStack {
                    Image(systemName: "gear")
                        .font(.system(size: 16, weight: .medium))
                    Text("Go to Safari Settings")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(content: {
                    Image(uiImage: createGradientImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    //                              .frame(width: 280)
                })
//                .background(.tm.accentSecondary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(.tm.container)
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
                //                    .foregroundColor(.black)
                
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
        }
    }
}


#Preview {
    EnableBlockerInstructionView()
}
