//
//  BlockAdsViewModel.swift
//  SurfShield
//
//  Created by Артур Кулик on 04.10.2025.
//

import SwiftUI
import SafariServices
import Combine

@MainActor
class BlockAdsViewModel: ObservableObject {
    @Published var waveProgress: Double = 0
    @Published var circleRotation: Double = 0
    @Published var isEnabled: Bool = false
    @Published var isShowInstructions: Bool = false
    @Published var isProcess: Bool = false
    @Published var waveHeight: CGFloat = 0
    @Published var isExtensionsEnabled: Bool = true
//    let contentBlockerService = ContentBlockerService()
    let safariExtensionChecker = SafariExtensionsChecker()
    
    let appInteractor = Executor.appInteractor
    
    let userDefaultsService = UserDefaultsService.shared
    let purchaseInteractor = Executor.purchaseInteractor
    private var blockingTask: Task<Void, Never>?
    private var continuousAnimationTask: Task<Void, Never>?
    var animationID = UUID() // Для отслеживания текущей анимации
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        subscribe()
    }
    
    func subscribe() {
        // Подписка на isBlockerEnable
        appInteractor.$appSettings
            .map { $0.isBlockerEnable }
            .print("DEBUG: Blocking state")
            .assign(to: &$isEnabled)
        
        // Подписка на isExtensionsEnabled
        appInteractor.$appSettings
            .map { $0.isExtensionsEnabled }
            .print("DEBUG: is extension enabled")
            .assign(to: &$isExtensionsEnabled)
        
        appInteractor.$appSettings
            .map { $0.isBlockerEnable }
            .sink { [self] isEnabled in
                if isEnabled {
                    startContinuousAnimation()
                } else {
                    stopContinuousAnimation()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Simple Toggle (NEW - без анимации)
    
    /// Простое переключение блокировщика без анимации
    func simpleToggleBlocking() {
        Task {
            isProcess = true
            
            let newState = !isEnabled
            await appInteractor.applyBlocker(newState)
            print("DEBUG: Blocking state vm \(isEnabled)")
            isProcess = false
            
        }
    }
    
    func checkBlockingActivity() {
        Task { @MainActor in
            let isExtensionsEnabled = await safariExtensionChecker.isExtensionEnabled()
            guard isExtensionsEnabled else {
                userDefaultsService.save(false, forKey: .adBlockerEnabled)
                self.isExtensionsEnabled = false
                self.isEnabled = false
                return
            }
            
            self.isExtensionsEnabled = true
            let isEnabled = userDefaultsService.load(Bool.self, forKey: .adBlockerEnabled) ?? false
            self.isEnabled = isEnabled
            if isEnabled {
                startContinuousAnimation()
            }
        }
    }
    
    func toggleBlocking() {
        if !isProcess {
            toggleAllBlocking()
        } else {
            cancelBlockingTask()
        }
    }
    
    func showInstructions() {
        isShowInstructions.toggle()
    }
    
    private func toggleAllBlocking() {
        animate()
        
        // Сразу определяем новое состояние
        let newState = !isEnabled
        
        blockingTask = Task {
            if !newState {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            
            if !Task.isCancelled {
                // Применяем новое состояние через RulesConverter
                await appInteractor.applyBlocker(newState)
//                await contentBlockerService.applyBlockingState(newState)
//                userDefaultsService.save(newState, forKey: .adBlockerEnabled)
                await MainActor.run {
                    // Обновляем состояние с анимацией
                    withAnimation(.bouncy(duration: 0.2)) {
                        isProcess = false
                        isEnabled = newState
                    }
                    
                    // Запускаем или останавливаем постоянную анимацию
                    if newState {
                        startContinuousAnimation()
                    } else {
                        stopContinuousAnimation()
                    }
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
    
    @MainActor
    public func checkPremiumAccess(showPaywall: Binding<Bool>, action: @escaping () -> Void) {
        Task {
            await purchaseInteractor.checkPremiumAccess(showPaywall: showPaywall, action: action)
        }
    }
}
