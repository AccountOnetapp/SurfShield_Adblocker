//
//  AppInteractor.swift
//  SurfShield
//
//  Created by Артур Кулик on 09.10.2025.
//

import Foundation

final class AppInteractor: ObservableObject {
    private let contentBlockerRepository: ContentBlockerRepository
    private let safariExtensionChecker: SafariExtensionsChecker
    private let userDefaultsService = UserDefaultsService.shared
    @Published public var appSettings: AppSettings
    
    init(contentBlockerRepository: ContentBlockerRepository, safariChecker: SafariExtensionsChecker, appSettings: AppSettings) {
        self.contentBlockerRepository = contentBlockerRepository
        self.safariExtensionChecker = safariChecker
        self.appSettings = appSettings
        
//        initialize()
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
    
    //MARK: Blocker
    func applyBlocker(_ isOn: Bool) async {
        await contentBlockerRepository.applyBlocker(isOn)
        
        // Для struct нужно создать новую копию, чтобы сработал @Published
        await MainActor.run {
//            var updatedSettings = appSettings
//            updatedSettings.isBlockerEnable = isOn
            appSettings.isBlockerEnable = isOn
        }
    }
    
    private func initialize() {
        
        appSettings = userDefaultsService.load(AppSettings.self, forKey: .appSettings) ?? .default
        
    }
}
