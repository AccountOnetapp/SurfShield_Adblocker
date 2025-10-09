//
//  ContentBlockerRepository.swift
//  SurfShield
//
//  Created by Артур Кулик on 09.10.2025.
//

import Foundation

class ContentBlockerRepository {
    let contentBlockerService: ContentBlockerService
//    let safariExtensionChecker: SafariExtensionsChecker
//    let userDefaultsService = UserDefaultsService.shared
    
    init(blockerService: ContentBlockerService) {
        self.contentBlockerService = blockerService
//        self.safariExtensionChecker = safariChecker
    }
    
    func applyBlocker(_ isOn: Bool) {
        Task {
            await contentBlockerService.applyBlockingState(isOn)
//            userDefaultsService.save(isOn, forKey: .adBlockerEnabled)
        }
    }
}
