//
//  DIContainer.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import Foundation

class DIContainer {
    let purchaseService = PurchaseService()
    let purchaseInteractor: PurchaseInteractor
    
    init() {
        self.purchaseInteractor = PurchaseInteractor(purchaseService: purchaseService)
    }
}
