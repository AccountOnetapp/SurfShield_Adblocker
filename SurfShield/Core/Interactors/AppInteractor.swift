//
//  AppInteractor.swift
//  SurfShield
//
//  Created by Артур Кулик on 09.10.2025.
//

import Foundation
import Combine
import SwiftUI

final class AppInteractor: ObservableObject {
    private let contentBlockerRepository: ContentBlockerRepository
    private let purchaseRepository: PurchaseRepository
    private let safariExtensionChecker: SafariExtensionsChecker
    let userDefaultsService = UserDefaultsService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published public var appSettings: AppSettings
    
    init(contentBlockerRepository: ContentBlockerRepository, purchaseRepository: PurchaseRepository, safariChecker: SafariExtensionsChecker, appSettings: AppSettings) {
        self.contentBlockerRepository = contentBlockerRepository
        self.purchaseRepository = purchaseRepository
        self.safariExtensionChecker = safariChecker
        self.appSettings = appSettings
        
        // Автоматически сохраняем настройки при любом изменении
        setupSettingsAutoSave()
    }
    
    public func appCheck() async {
        await blockerCheck()
        await checkPremium()
    }
    
    private func setupSettingsAutoSave() {
        $appSettings
            .dropFirst() // Пропускаем начальное значение из init
            .sink { [weak self] newSettings in
                guard let self = self else { return }
                // Сохраняем в UserDefaults
                print("DEBUG: app settings AP \(newSettings.advancedProtection)")
                self.userDefaultsService.save(newSettings, forKey: .appSettings)
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func checkPremium() async {
        let isPurchaseActive = purchaseRepository.isSubscriptionActive()
        if !isPurchaseActive {
            await disablePremiumFeatures()
        }
    }
    
    @MainActor
    ///Проверяет на присутствие подписки, если она есть, то выполняется блок action, если нет, то тоглится showPaywall ( Обязательно нужно привязывать переменную которая тригерит paywall )
    func checkPremiumAccess(showPaywall: Binding<Bool>, action: @escaping () -> Void) async {
        let hasPremium = purchaseRepository.isSubscriptionActive()
//        let products = await purchaseService.getProducts()
        if hasPremium {
            // Есть подписка - выполняем действие
            action()
        } else {
            // Нет подписки - показываем paywall
            showPaywall.wrappedValue = true
        }
    }
    
    @MainActor
    private func disablePremiumFeatures() async {
        await contentBlockerRepository.applyBlocker(false)
        appSettings.isBlockerEnable = false
        appSettings.enableBrowserDarkMode = false
        appSettings.advancedProtection = false
    }
    
    @MainActor
    ///Mark check with app start
    func blockerCheck() async {
        let isExtensionsEnabled = await safariExtensionChecker.isExtensionEnabled()
        guard isExtensionsEnabled else {
            await applyBlocker(false)
            appSettings.isBlockerEnable = false
            appSettings.isExtensionsEnabled = false
            return
        }
        appSettings.isExtensionsEnabled = true
    }
    
    @MainActor
    //MARK: Blocker
    func applyBlocker(_ isOn: Bool) async {
        await contentBlockerRepository.applyBlocker(isOn)
        if !isOn {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
        appSettings.isBlockerEnable = isOn
    }
}
