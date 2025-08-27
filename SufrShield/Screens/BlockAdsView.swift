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
        case connecting
        case disconnecting
    }
    
    @Published var waveProgress: Double = 0
    @Published var circleRotation: Double = 0
    @Published var isEnabled: Bool = false
    @Published var isProcess: Bool = false
    @Published var waveHeight: CGFloat = 0
    
    @Published var blockingState: BlockingState = .disabled
    
    private var blockingTask: Task<Void, Never>?
    private var continuousAnimationTask: Task<Void, Never>?
    var animationID = UUID() // Для отслеживания текущей анимации
    
    init() { }
    
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
                    // Отменяем анимацию и сбрасываем состояние
                    
                    // Обновляем состояние с анимацией
                    withAnimation(.bouncy(duration: 0.2)) {
                        isEnabled.toggle()
                        isProcess = false
                    }
                    
                    // Запускаем или останавливаем постоянную анимацию
                    if isEnabled {
                        startContinuousAnimation()
                    } else {
                        stopContinuousAnimation()
                    }
                    
                    RulesConverter.start()
                }
            }
        }
    }

    
    func animate() {
        animationID = UUID()

        // Disable previous animation
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            circleRotation = 0
            waveHeight = 0
            waveProgress = 0
        }

        withAnimation(.bouncy(duration: 0.2, extraBounce: 0.1)) {
            isProcess = true
        }
        
        withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
            self.waveProgress = 1.0
        }
        
//        withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
            self.circleRotation = 360
//        }
    }
    
    func cancelBlockingTask() {
        blockingTask?.cancel()
        blockingTask = nil
        
        // Обновляем состояние
        withAnimation(.easeInOut(duration: 0.2)) {
            isProcess = false
        }
        
        // Если блокировка не включена, останавливаем анимацию
        if !isEnabled {
            stopContinuousAnimation()
        }
    }
    
    private func resetAnimations() {
        // Отменяем текущую анимацию
        animationID = UUID()
        
        // Отключаем анимацию для сброса
        var transaction = Transaction()
        transaction.disablesAnimations = true
        
        withTransaction(transaction) {
            circleRotation = 0
            waveHeight = 0
            waveProgress = 0
        }
    }
    
    func startContinuousAnimation() {
        stopContinuousAnimation() // Останавливаем предыдущую анимацию если есть
        
        animationID = UUID()
        
        // Сбрасываем состояние
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            circleRotation = 0
            waveProgress = 0
        }
        
        // Запускаем постоянную анимацию
        withAnimation(.easeInOut(duration: 1.0).repeatForever()) {
            self.waveProgress = 1.0
        }
        
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            self.circleRotation = 360
        }
    }
    
    private func stopContinuousAnimation() {
        continuousAnimationTask?.cancel()
        continuousAnimationTask = nil
        
        // Сбрасываем анимации
        resetAnimations()
    }
}



// MARK: - View
struct BlockAdsView: View {
    @StateObject private var viewModel = BlockAdsViewModel()
    
    var body: some View {
        content
    }
    

    let id = UUID()
    var content: some View {
        ZStack {
            // Анимированный фон с градиентом
            BackgroundGradient(isHighlight: viewModel.isEnabled)
                .ignoresSafeArea()
            
            // Анимированные частицы на фоне
            ParticlesView()
                .opacity(0.3)
            
            VStack {
                Spacer()
                
                VStack(spacing: 24) {
                    blockAdsButton
                    
                    // Статус кнопки с лоадером
                    VStack(spacing: 12) {
                        Text(buttonStatusTitle)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(.tm.title)
                            .opacity(viewModel.isProcess ? 0.7 : 1.0)
                        
                        // Красивый лоадер для процесса
                        ProcessLoader()
                            .transition(.scale.combined(with: .opacity))
                            .opacity(viewModel.isProcess ? 1 : 0)
                    }
                    .id(viewModel.animationID)
                }
                
                Spacer()
                
                // Описание приложения
                VStack(spacing: 16) {
                    Text("Blocking advertising")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.tm.accentSecondary)
                    
                    Text("Click the button to activate or deactivate advertising blocking in Safari")
                        .font(.body)
                        .foregroundColor(.tm.subTitle.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            // Запускаем анимацию если блокировка уже включена
            if viewModel.isEnabled {
                viewModel.startContinuousAnimation()
            }
        }
        .onDisappear {
            viewModel.cancelBlockingTask()
        }
    }

    @ViewBuilder
    var blockAdsButton: some View {
        AnimatedBlockButton(
            isEnabled: viewModel.isEnabled,
            isProcess: viewModel.isProcess,
            waveProgress: viewModel.waveProgress,
            circleRotation: viewModel.circleRotation,
            animationID: viewModel.animationID,
            onTap: {
                // Haptic feedback
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                viewModel.toggleBlocking()
            }
        )
    }
    
    private var buttonStatusTitle: String {
        if viewModel.isProcess {
            return viewModel.isEnabled ? "Отключение" : "Подключение"
        } else {
            return viewModel.isEnabled ? "Включено" : "Выключено"
        }
    }

}

// MARK: - Animated Block Button
struct AnimatedBlockButton: View {
    let isEnabled: Bool
    let isProcess: Bool
    let waveProgress: Double
    let circleRotation: Double
    let animationID: UUID
    let onTap: () -> Void
    
    private let waveSize: CGFloat = 160
    private let waveCount = 4
    
    var body: some View {
        ZStack {
            // Основная кнопка с дугой загрузки
            if isEnabled {
                makeEnabledStateButton()
            } else {
                makeDisabledStateButton()
            }
            
            // Overlay с иконкой и состоянием
            buttonContentOverlay
        }
        .onTapGesture {
            onTap()
        }
        .scaleEffect(isProcess ? 0.94 : 1.0)
        .background {
            if isProcess {
                ForEach(0..<8) { index in
                    ParticleView(index: index, isActive: isProcess)
                        .opacity(0.6)
                }
            }
        }
    }
    
    @ViewBuilder
    private var buttonContentOverlay: some View {
        ZStack {
            // Пульсирующее кольцо для активного состояния
            if isEnabled && !isProcess {
                Circle()
                    .stroke(.white.opacity(0.2), lineWidth: 2)
                    .frame(width: 70, height: 70)
                    .scaleEffect(1.0)
                    .opacity(0.8)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isEnabled)
                
                Circle()
                    .stroke(.white.opacity(0.1), lineWidth: 1)
                    .frame(width: 85, height: 85)
                    .scaleEffect(1.1)
                    .opacity(0.6)
                    .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: isEnabled)
            }
            
            // Дополнительное свечение для включенного состояния
            if isEnabled && !isProcess {
                Image(systemName: iconName)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.tm.accentSecondary.opacity(0.2))
                    .scaleEffect(1.15)
                    .blur(radius: 6)
            }
            
            // Основная иконка
            Image(systemName: iconName)
                .font(.system(size: 32, weight: .medium))
                .foregroundStyle(iconColor)
                .shadow(color: iconShadow, radius: iconShadowRadius)
                .scaleEffect(isProcess ? 0.9 : 1.0)
                .rotationEffect(.degrees(isProcess ? circleRotation : 0))
                .animation(.easeInOut(duration: 0.2), value: isProcess)
                .animation(isProcess ? .linear(duration: 2.0).repeatForever(autoreverses: false) : .none, value: circleRotation)
        }
    }
    

    
    private var iconName: String {
        if isProcess {
            return "arrow.triangle.2.circlepath"
        } else {
            return "power"
        }
    }
    
    private var iconColor: Color {
        if isProcess {
            return .white.opacity(0.9)
        } else if isEnabled {
            // Для включенного состояния - белый с легким свечением
            return .white
        } else {
            // Для выключенного состояния - приглушенный белый
            return .white.opacity(0.7)
        }
    }
    
    private var iconShadow: Color {
        if isProcess {
            return .clear
        } else if isEnabled {
            // Красивое свечение для включенного состояния
            return .tm.accentSecondary
        } else {
            return .clear
        }
    }
    
    private var iconShadowRadius: CGFloat {
        if isEnabled && !isProcess {
            return 12
        } else {
            return 0
        }
    }
    
    private func makeDisabledStateButton() -> some View {
        WaveShape(waveCount: 0, waveHeight: 0, progress: waveProgress)
            .fill(
                LinearGradient(
                    colors: [.tm.container, .tm.container.opacity(0.9)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 160, height: 160)
            .scaleEffect(isProcess ? 0.94 : 1.0)
    }
    
    private func makeEnabledStateButton() -> some View {
        ForEach(1..<12) { index in
            makeWaveCircle(
                duration: 3 + Double(index) / 4,
                opacity: Double(index) / 20,
                rotationVector: index % 2 == 0,
                colors: [.tm.accentSecondary, .tm.accent]
            )
            .scaleEffect(CGSize(width: 1 - (Double(index) * 0.005), height: 1 - (Double(index) * 0.005)) )
        }
    }
    
    private func makeWaveCircle(duration: Double, opacity: CGFloat, rotationVector: Bool, colors: [Color]) -> some View {
        WaveShape(waveCount: waveCount, waveHeight: 3, progress: waveProgress)
            .fill(
                LinearGradient(
                    colors: colors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: waveSize, height: waveSize)
            .rotationEffect(.degrees(opacity * 140)) // Сдвиг по часовой стрелке чтобы анимация начиналась не с нулевого положения
            .rotationEffect(.degrees(rotationVector ? -circleRotation : circleRotation))
            .opacity(opacity)
            .animation(.linear(duration: duration).repeatForever(autoreverses: false), value: circleRotation)
            .id(animationID)
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


// MARK: - Process Loader
struct ProcessLoader: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(.tm.accentSecondary.opacity(0.8))
                    .frame(width: 6, height: 6)
                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                    .opacity(isAnimating ? 1.0 : 0.4)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

#Preview {
    BlockAdsView()
}

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

