//
//  PurchaseService.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import Foundation
import ApphudSDK

// MARK: - Errors

enum PurchaseError: Error {
    case noProducts
    case purchaseFailed
    case restoreFailed
    case cancelled
}

// MARK: - Result

struct PurchaseResult {
    let subscription: ApphudSubscription?
    let isSuccess: Bool
    let error: Error?
}

// MARK: - Service

class PurchaseService {
    
    // MARK: - Products
    
    @MainActor
    /// Загрузить продукты из Apphud
    func fetchProducts() async -> [ApphudProduct] {
        await withCheckedContinuation { continuation in
            Apphud.fetchPlacements(maxAttempts: 5) { placements, error in
                let productsArrays = placements.compactMap { $0.paywall?.products }
                let allProducts = productsArrays.flatMap { $0 }
                continuation.resume(returning: allProducts)
            }
            
//            Apphud.paywallsDidLoadCallback { paywalls, error  in
//                let products = paywalls.flatMap { $0.products }
//                continuation.resume(returning: products)
//            }
        }
    }
    
    // MARK: - Purchase
    
    @MainActor
    /// Купить продукт
    func purchase(_ product: ApphudProduct) async -> PurchaseResult {
        await withCheckedContinuation { continuation in
            Apphud.purchase(product) { result in
                let purchaseResult = PurchaseResult(
                    subscription: result.subscription,
                    isSuccess: result.subscription?.isActive() ?? false,
                    error: result.error
                )
                continuation.resume(returning: purchaseResult)
            }
        }
    }
    
    @MainActor
    /// Восстановить покупки
    func restorePurchases() async throws -> [ApphudSubscription] {
        try await withCheckedThrowingContinuation { continuation in
            Apphud.restorePurchases { subscriptions, _, error in
                if error != nil {
                    continuation.resume(throwing: PurchaseError.restoreFailed)
                } else {
                    continuation.resume(returning: subscriptions ?? [])
                }
            }
        }
    }
    
    // MARK: - Status
    
    /// Проверить активную подписку
    func hasActiveSubscription() -> Bool {
        return Apphud.hasActiveSubscription()
    }
    
    @MainActor
    /// Получить текущую подписку
    func getSubscription() -> ApphudSubscription? {
        return Apphud.subscription()
    }
    
    @MainActor
    /// Получить все подписки
    func getSubscriptions() -> [ApphudSubscription] {
        return Apphud.subscriptions() ?? []
    }
}
