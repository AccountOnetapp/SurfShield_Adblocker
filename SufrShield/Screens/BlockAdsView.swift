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
    @Published var rulesCount: Int = 0
    @Published var lastUpdateTime: Date = Date()
    
    private var blockingTask: Task<Void, Never>?
    
    init() {
        // Загружаем текущий статус блокировки
//        isEnabled = RuleConverterBridge.isAdBlockingEnabled()
//        rulesCount = RuleConverterBridge.getRulesCount()
        lastUpdateTime = Date()
    }
    
    func toggleBlocking() {
        if !isProcess {
            toggleAllBlocking()
        } else {
            cancelBlockingTask()
        }
    }
    
    private func toggleAllBlocking() {
        animate()
        blockingTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            
            if !Task.isCancelled {
                await MainActor.run {
                    withAnimation(.bouncy(duration: 0.3)) {
                        isEnabled.toggle()
                        isProcess = false
                        
                        // Обновляем статус блокировки в системе
//                        RuleConverterBridge.setAdBlockingEnabled(isEnabled)
//                        
//                        // Обновляем информацию о правилах
//                        rulesCount = RuleConverterBridge.getRulesCount()
                        lastUpdateTime = Date()
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
        
        circleRotation = 360
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
            // Анимированный фон с градиентом
            LinearGradient(
                colors: viewModel.isEnabled 
                    ? [Color.tm.background, Color.tm.background.opacity(0.8), Color.tm.accentSecondary.opacity(0.1)]
                    : [Color.tm.background, Color.tm.background.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Анимированные частицы на фоне
            ParticlesView()
                .opacity(0.3)
            
            VStack {
                Spacer()
                
                blockAdsButton
                
                Spacer()
                
                // Улучшенное описание с анимацией
                VStack(spacing: 20) {
                    HStack(spacing: 12) {
                        Text("Blocking advertising")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.tm.accentSecondary)
                    }
                    
                    Text("Click the button to activate advertising blocking in all applications")
                        .font(.body)
                        .foregroundColor(.tm.subTitle.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .opacity(viewModel.isProcess ? 0.6 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: viewModel.isProcess)
                    
                    // Информация о правилах блокировки
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "list.bullet")
                                .font(.caption)
                                .foregroundStyle(.tm.accentTertiary)
                            
                            Text("Правил блокировки: \(viewModel.rulesCount)")
                                .font(.caption)
                                .foregroundStyle(.tm.subTitle)
                        }
                        
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundStyle(.tm.accentTertiary)
                            
                            Text("Обновлено: \(viewModel.lastUpdateTime, formatter: timeFormatter)")
                                .font(.caption)
                                .foregroundStyle(.tm.subTitle)
                        }
                        
                        // Кнопки управления
                        HStack(spacing: 8) {
                            // Кнопка обновления правил
                            Button(action: {
                                
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.caption)
                                    Text("Обновить правила")
                                        .font(.caption)
                                }
                                .foregroundStyle(.tm.accentSecondary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.tm.accentSecondary.opacity(0.1))
                                )
                            }
                            .disabled(viewModel.isProcess)
                            
                            // Кнопка диагностики
                            Button(action: {
                                // Здесь можно показать alert с результатами диагностики
                            }) {
                                HStack {
                                    Image(systemName: "stethoscope")
                                        .font(.caption)
                                    Text("Диагностика")
                                        .font(.caption)
                                }
                                .foregroundStyle(.tm.accentTertiary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.tm.accentTertiary.opacity(0.1))
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.tm.container.opacity(0.3))
                    )
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
        ZStack {
            // Основная кнопка с дугой загрузки
            
            mainButtonShape
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "power")
                            .font(.system(size: 40, weight: .medium))
                            .foregroundStyle(viewModel.isEnabled ? .tm.accentSecondary : .white)
                            .shadow(color: .tm.accentSecondary.opacity(viewModel.isEnabled ? 0.6 : 0), radius: 3)
                        
                        Text(viewModel.isEnabled ? "Turn off" : "Turn on")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                )
                .scaleEffect(viewModel.isProcess ? 0.97 : 1.0)
                .onTapGesture {
                    // Haptic feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    viewModel.toggleBlocking()
                }
                .background(
                    ZStack {
                        otherCircles
                            .opacity(viewModel.isProcess ? 1 : 0)
                        
                        // Анимированные частицы вокруг кнопки
                        if viewModel.isProcess {
                            ForEach(0..<8) { index in
                                ParticleView(index: index, isActive: viewModel.isProcess)
                                    .opacity(0.2)
                            }
                        }
                    }
                )
        }
    }

    
    @ViewBuilder
    var mainButtonShape: some View {
        WaveShape(waveCount: 6, waveHeight: viewModel.waveHeight, progress: viewModel.waveProgress)
            .fill(
                LinearGradient(
                    colors: viewModel.isProcess ? [.tm.accentSecondary.opacity(0.4), .tm.accentTertiary.opacity(0.4)] : [.tm.container, .tm.container.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 160, height: 160)
            .rotationEffect(.degrees(viewModel.circleRotation))
            .opacity(viewModel.isProcess ? 0 : 1)
    }
    
    var otherCircles: some View {
        ForEach(1..<7) { index in
            makeWaveCircle(duration: 2 + Double(index) / 4, opacity: Double(index) / 8, rotationVector: index % 2 == 0)
        }
    }
    
    func makeWaveCircle(duration: Double, opacity: CGFloat, rotationVector: Bool) -> some View {
        WaveShape(waveCount: 6, waveHeight: 2, progress: viewModel.waveProgress)
            .fill(
                LinearGradient(
                    colors: [.tm.accentSecondary.opacity(0.6), .tm.accent.opacity(0.6)],
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

// MARK: - Time Formatter
private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .short
    formatter.locale = Locale(identifier: "ru_RU")
    return formatter
}()

struct ParticlesView: View {
    @State private var animation = false
    
    var body: some View {
        ZStack {
            ForEach(0..<20) { index in
                Circle()
                    .fill(.tm.accentTertiary.opacity(0.1))
                    .frame(width: CGFloat.random(in: 2...6))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...6))
                        .repeatForever(autoreverses: true),
                        value: animation
                    )
            }
        }
        .onAppear {
            animation.toggle()
        }
    }
}

// MARK: - Individual Particle
struct ParticleView: View {
    let index: Int
    let isActive: Bool
    
    @State private var animation = false
    
    var body: some View {
        Circle()
            .fill(.tm.accentSecondary)
            .frame(width: 4, height: 4)
            .scaleEffect(animation ? 0.1 : 1.0)
            .opacity(animation ? 0 : 0.8)
            .position(
                x: 80 + cos(Double(index) * .pi / 4) * 100,
                y: 80 + sin(Double(index) * .pi / 4) * 100
            )
            .animation(
                .easeOut(duration: 1.5)
                .repeatForever(autoreverses: false)
                .delay(Double(index) * 0.1),
                value: animation
            )
            .onAppear {
                if isActive {
                    animation.toggle()
                }
            }
    }
}

