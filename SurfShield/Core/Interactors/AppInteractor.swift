//
//  AppInteractor.swift
//  SurfShield
//
//  Created by Артур Кулик on 09.10.2025.
//

import Foundation

final class AppInteractor {
    let contentBlockerRepository: ContentBlockerRepository
    let safariExtensionChecker: SafariExtensionsChecker
    let userDefaultsService = UserDefaultsService.shared
    
    init(contentBlockerRepository: ContentBlockerRepository, safariChecker: SafariExtensionsChecker) {
        self.contentBlockerRepository = contentBlockerRepository
        self.safariExtensionChecker = safariChecker
    }
    
    //MARK: Blocker
    func applyBlocker(_ isOn: Bool) async {
        let isExtensionsEnabled = await safariExtensionChecker.isExtensionEnabled()
        isExtensionsEnabled ? contentBlockerRepository.applyBlocker(isOn) : contentBlockerRepository.applyBlocker(false)
        
    }
}
