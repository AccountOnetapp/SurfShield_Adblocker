//
//  DIContainer.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import Foundation

class DIContainer {
    let purchaseService = PurchaseService()
    let purchaseInteractor: PurchaseRepository
    
    init() {
        self.purchaseInteractor = PurchaseRepository(purchaseService: purchaseService)
    }
}
