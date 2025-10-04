//
//  MainButton.swift
//  SurfShield
//
//  Created by Артур Кулик on 04.10.2025.
//

import SwiftUI

struct MainButton: View {
    var title: String
    var onTap: () -> Void
    
    var body: some View {
        Button(action: {
            onTap()
        }) {
            Text(title)
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
