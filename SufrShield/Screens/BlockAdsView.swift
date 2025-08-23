//
//  BlockAdsView.swift
//  SufrShield
//
//  Created by Артур Кулик on 23.08.2025.
//

import SwiftUI
import Combine
// MARK: - ViewModel
@MainActor
class BlockAdsViewModel: ObservableObject {
    enum BlockingState {
        case enabled
        case disabled
        case process
    }
    
    @Published var waveProgress: Double = 0
    @Published var circleRotation: Double = 0
    @Published var isEnabled: Bool = false
    @Published var isProcess: Bool = false
    @Published var waveHeight: CGFloat = 0
    
    private var blockingTask: Task<Void, Never>?
    
    func toggleBlocking() {
        if !isProcess {
            toggleAllBlocking()
        } else {
            cancelBlockingTask()
        }
        //        if isEnabled {
        //            turnOffBlocking()
        //        } else {
        //            turnOnBlocking()
        //        }
    }
    
    
    private func toggleAllBlocking() {
        animate()
        blockingTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation(.bouncy(duration: 0.3)) {
                        isEnabled.toggle()
//                        circleRotation = 0
//                        waveHeight = 0
//                        waveProgress = 0
                        isProcess = false
                    }
                    resetAnimations()
                }
            }
        }
    }
    
    private func animate() {
        
        withAnimation {
            isProcess = true
        }
        
        // Animation not working
        waveHeight = 2
        
        
        withAnimation(.easeInOut(duration: 1.0)) {
            waveProgress = 1.0
        }
        
//        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
        withAnimation(.linear(duration: 2.0)) {
            circleRotation = 360
        }
    }
    
    func cancelBlockingTask() {
        blockingTask?.cancel()
        blockingTask = nil
        withAnimation(.easeInOut(duration: 0.3)) {
            circleRotation = 0
            isProcess = false
        }
        resetAnimations()
    }
    
    private func resetAnimations() {
        // Отключаем анимацию для сброса
        var transaction = Transaction()
        transaction.disablesAnimations = true
        
        withTransaction(transaction) {
            circleRotation = 0
            waveHeight = 0
            waveProgress = 0
        }
    }
}



// MARK: - View
struct BlockAdsView: View {
    @StateObject private var viewModel = BlockAdsViewModel()
    let waveSize: CGFloat = 160
    var body: some View {
        content
    }
    
    var content: some View {
        ZStack {
            // Фон
            Color.tm.background
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                blockAdsButton
                
                Spacer()
                
                // Описание
                VStack(spacing: 16) {
                    Text("Блокировка рекламы")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.tm.accentTertiary)
                    
                    Text("Нажмите кнопку для активации блокировки рекламы во всех приложениях")
                        .font(.body)
                        .foregroundColor(.tm.subTitle.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 50)
            }
        }
        .onDisappear {
            viewModel.cancelBlockingTask()
        }
    }
    
    @ViewBuilder
    var blockAdsButton: some View {
        // Основная кнопка с дугой загрузки
        mainButtonShape
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "power")
                        .font(.system(size: 40, weight: .medium))
                        .foregroundStyle(viewModel.isEnabled ? .white : .tm.error)
                    
                    Text(viewModel.isEnabled ? "Выключить" : "Включить")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                }
            )
            .scaleEffect(viewModel.isProcess ? 0.97 : 1.0)
            .onTapGesture {
                viewModel.toggleBlocking()
            }
            .background(
                otherCircles
                    .opacity(viewModel.isProcess ? 1 : 0)
            )
        
    }
    
    @ViewBuilder
    var mainButtonShape: some View {
        WaveShape(waveCount: 6, waveHeight: viewModel.waveHeight, progress: viewModel.waveProgress)
            .fill(
                LinearGradient(
                    colors: [.tm.container, .tm.container.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 160, height: 160)
            .rotationEffect(.degrees(viewModel.circleRotation))
            .opacity(viewModel.isProcess ? 0.4 : 1)
    }
    
    var otherCircles: some View {
        ForEach(0..<5) { index in
            makeWaveCircle(duration: 2 + Double(index) / 4, opacity: Double(index) / 8, rotationVector: index % 2 == 0)
        }
    }
    
    func makeWaveCircle(duration: Double, opacity: CGFloat, rotationVector: Bool) -> some View {
        WaveShape(waveCount: 6, waveHeight: 2, progress: viewModel.waveProgress)
            .fill(
                LinearGradient(
                    colors: [.tm.accentSecondary.opacity(0.6), .tm.accentTertiary.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: waveSize, height: waveSize)
            .rotationEffect(.degrees(rotationVector ? -viewModel.circleRotation : viewModel.circleRotation))
            .opacity(opacity)
            .animation(.linear(duration: duration), value: viewModel.circleRotation)
            .shadow(color: .tm.accentSecondary.opacity(0.1), radius: 40, x: 0, y: 0)
    }
}

// MARK: - Custom Shape
// Кастомная волнистая форма
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
    BlockAdsView()
}
