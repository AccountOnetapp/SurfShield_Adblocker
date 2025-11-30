//
//  PurchaseInteractor.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import Foundation
import SwiftUI
import ApphudSDK
import StoreKit

class PurchaseRepository {
    //TODO: Implement PurchaseService
    var purchaseService: PurchaseService
    
    init(purchaseService: PurchaseService) {
        self.purchaseService = purchaseService
    }
    
    //TODO: Добавить возвращаемое значение
    func purchase(_ type: SubscriptionType) async throws -> Bool {
        do {
            let purchaseResult = try await purchaseService.purchase(id: type.id)
            return purchaseResult.success
        } catch {
            throw error
        }
    }
    
    func restore() async throws -> RestoreResult {
        try await purchaseService.restore()
    }
    
    @MainActor
    func isSubscriptionActive() async -> Bool {
//        return await purchaseService.hasActiveSubscription()
                                    return true
    }
    
    /// Альтернативная проверка подписки (более надежная)
    func isSubscriptionActiveAlternative() async -> Bool {
        return await purchaseService.hasActiveSubscriptionAlternative()
    }
    
    func getProduct(_ type: SubscriptionType) async throws -> Product {
//        throw PurchaseError.noProductWithThisId
        try await purchaseService.getProduct(id: type.id)
    }
}
