//
//  DIContainer.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import Foundation

class DIContainer {
    let purchaseService = PurchaseService()
    let blockerService = ContentBlockerService()
    let safariChecker = SafariExtensionsChecker()
//    let appSettings = AppSettings()
    let purchaseInteractor: PurchaseRepository
    let appInteractor: AppInteractor
    
    
    init() {
        let appSettings = UserDefaultsService.shared.load(AppSettings.self, forKey: .appSettings) ?? .default
        
        self.purchaseInteractor = PurchaseRepository(purchaseService: purchaseService)
        
        let blockerRepository = ContentBlockerRepository(blockerService: blockerService)
        
        self.appInteractor = AppInteractor(contentBlockerRepository: blockerRepository, safariChecker: safariChecker, appSettings: appSettings)
    }
}
