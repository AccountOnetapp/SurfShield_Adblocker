//
//  PurchaseInteractor.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import Foundation
import SwiftUI
import ApphudSDK

class PurchaseRepository {
    //TODO: Implement PurchaseService
    var purchaseService: PurchaseService
    
    init(purchaseService: PurchaseService) {
        self.purchaseService = purchaseService
    }
    
    //TODO: Добавить возвращаемое значение
    func purchase(_ type: SubscriptionType) async -> Bool {
        do {
            let purchaseResult = try await purchaseService.purchase(id: type.id)
            return purchaseResult.success
        } catch {
            return false
        }
    }
    
    func isSubscriptionActive() -> Bool {
        return purchaseService.hasActiveSubscription()
    }
}
