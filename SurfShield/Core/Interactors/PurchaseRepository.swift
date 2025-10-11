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
    
    func restore() async throws -> Bool {
        let restored = try await purchaseService.restore()
        return restored.hasActiveSubscriptions
    }
    
    func isSubscriptionActive() -> Bool {
        return purchaseService.hasActiveSubscription()
    }
    
    func getProduct(_ type: SubscriptionType) async throws -> Product {
//        throw PurchaseError.noProductWithThisId
        try await purchaseService.getProduct(id: type.id)
    }
}
