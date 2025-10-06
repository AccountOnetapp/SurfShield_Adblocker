//
//  WaveButton.swift
//  SurfShield
//
//  Created by Артур Кулик on 06.10.2025.
//

import SwiftUI

struct WaveShape: Shape {
    let waveCount: Int
    let waveHeight: CGFloat
    let progress: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let adjustedRadius = radius - waveHeight
        
        // Если progress == 0, рисуем обычный круг
        if progress == 0 {
            path.addArc(
                center: center,
                radius: adjustedRadius,
                startAngle: .degrees(0),
                endAngle: .degrees(360),
                clockwise: false
            )
            path.closeSubpath()
            return path
        }
        
        // Начинаем с верхней точки
        let startAngle = -CGFloat.pi / 2
        
        // Рисуем волнистую окружность
        for i in stride(from: 0, through: 360, by: 1) {
            let angle = startAngle + CGFloat(i) * .pi / 180
            let waveOffset = sin(CGFloat(i) * CGFloat(waveCount) * .pi / 180) * waveHeight * CGFloat(progress)
            let currentRadius = adjustedRadius + waveOffset
            
            let point = CGPoint(
                x: center.x + currentRadius * cos(angle),
                y: center.y + currentRadius * sin(angle)
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        // Замыкаем путь
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    WaveShape(waveCount: 15, waveHeight: 125, progress: 152)
}
