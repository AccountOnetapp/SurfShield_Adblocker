//
//  DIContainer.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import Foundation

class DIContainer {
    let purchaseService = PurchaseService()
    let safariChecker = SafariExtensionsChecker()
    let purchaseRepository: PurchaseRepository
    let appInteractor: AppInteractor
    
    
    init() {
        let appSettings = UserDefaultsService.shared.load(AppSettings.self, forKey: .appSettings) ?? .default
        
        self.purchaseRepository = PurchaseRepository(purchaseService: purchaseService)
        
        let blockerRepository = ContentBlockerRepository()
        
        self.appInteractor = AppInteractor(contentBlockerRepository: blockerRepository, purchaseRepository: purchaseRepository, safariChecker: safariChecker, appSettings: appSettings)
    }
}
