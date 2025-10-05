//
//  BlockAdsViewModel.swift
//  SurfShield
//
//  Created by Артур Кулик on 04.10.2025.
//

import SwiftUI
import SafariServices

@MainActor
class BlockAdsViewModel: ObservableObject {
    @Published var waveProgress: Double = 0
    @Published var circleRotation: Double = 0
    @Published var isEnabled: Bool = false
    @Published var isProcess: Bool = false
    @Published var waveHeight: CGFloat = 0
    let contentBlockerService = ContentBlockerService()
    let safariExtensionChecker = SafariExtensionsChecker()
    let userDefaultsService = UserDefaultsService.shared
    
    private var blockingTask: Task<Void, Never>?
    private var continuousAnimationTask: Task<Void, Never>?
    var animationID = UUID() // Для отслеживания текущей анимации
    
    init() {
        // Инициализируем блокировщик с сохраненным состоянием
        checkBlockingActivity()
    }
    
    func checkBlockingActivity() {
        Task {
            let isExtensionsEnabled = await safariExtensionChecker.isExtensionEnabled()
            guard isExtensionsEnabled else {
                userDefaultsService.save(false, forKey: .adBlockerEnabled)
                return
            }
            let isEnabled = userDefaultsService.load(Bool.self, forKey: .adBlockerEnabled)
            self.isEnabled = isEnabled ?? false
        }
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
        
        // Сразу определяем новое состояние
        let newState = !isEnabled
        
        blockingTask = Task {
            if !newState {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
            
            if !Task.isCancelled {
                // Применяем новое состояние через RulesConverter
                await contentBlockerService.applyBlockingState(newState)
                userDefaultsService.save(newState, forKey: .adBlockerEnabled)
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
    
    // MARK: - Extension Reload Methods
    func reloadExtension(bundleId: String) {
        Task {
            print("🔄 Перезагружаем расширение: \(bundleId)")
            do {
                try await SFContentBlockerManager.reloadContentBlocker(withIdentifier: bundleId)
                print("✅ Расширение \(bundleId) успешно перезагружено")
            } catch {
                print("❌ Ошибка перезагрузки расширения \(bundleId): \(error.localizedDescription)")
            }
        }
    }
    
    func reloadAdBlocker() {
        reloadExtension(bundleId: "com.surfshield.app.adblocker")
    }
    
    func reloadPrivacy() {
        reloadExtension(bundleId: "com.surfshield.app.privacy")
    }
    
    func reloadBanners() {
        reloadExtension(bundleId: "com.surfshield.app.banners")
    }
    
    func reloadTrackers() {
        reloadExtension(bundleId: "com.surfshield.app.trackers")
    }
    
    func reloadAdvanced() {
        reloadExtension(bundleId: "com.surfshield.app.advanced")
    }
}
