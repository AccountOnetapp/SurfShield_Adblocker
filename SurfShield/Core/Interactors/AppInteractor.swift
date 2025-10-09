//
//  AppInteractor.swift
//  SurfShield
//
//  Created by Артур Кулик on 09.10.2025.
//

import Foundation
import Combine

final class AppInteractor: ObservableObject {
    private let contentBlockerRepository: ContentBlockerRepository
    private let safariExtensionChecker: SafariExtensionsChecker
    let userDefaultsService = UserDefaultsService.shared
    private var cancellables = Set<AnyCancellable>()
    
    @Published public var appSettings: AppSettings
    
    init(contentBlockerRepository: ContentBlockerRepository, safariChecker: SafariExtensionsChecker, appSettings: AppSettings) {
        self.contentBlockerRepository = contentBlockerRepository
        self.safariExtensionChecker = safariChecker
        self.appSettings = appSettings
        
        // Автоматически сохраняем настройки при любом изменении
        setupSettingsAutoSave()
    }
    
    private func setupSettingsAutoSave() {
        $appSettings
            .dropFirst() // Пропускаем начальное значение из init
//            .debounce(for: .milliseconds(3), scheduler: DispatchQueue.main) // Группируем быстрые изменения
            .sink { [weak self] newSettings in
                guard let self = self else { return }
                
                // Сохраняем в UserDefaults
                self.userDefaultsService.save(newSettings, forKey: .appSettings)
                
                // Синхронизируем с UserDefaultsObserver
//                UserDefaultsObserver.shared.updateAppSettings(newSettings)
                
                print("✅ AppInteractor: Настройки автоматически сохранены")
            }
            .store(in: &cancellables)
    }
    
    func appCheck() {
        Task {
            await blockerCheck()
        }
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
//        await MainActor.run {
            appSettings.isBlockerEnable = isOn
//        }
    }
    
}
