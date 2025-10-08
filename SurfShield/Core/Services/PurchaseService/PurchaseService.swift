//
//  PurchaseService.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import Foundation
import ApphudSDK
import StoreKit

// MARK: - Errors

enum PurchaseError: Error {
    case noProducts
    case noProductWithThisId
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
    // ID приходит из Purchase Interactor из энума SubscriptionType
    func purchase(id: String) async throws -> ApphudAsyncPurchaseResult {
        let products = await getProducts()
        let product = products.first { $0.id == id }
        
        guard let product else { throw PurchaseError.noProductWithThisId }
        
        let asyncResult = await Apphud.purchase(product)
        
        guard asyncResult.error == nil else { throw asyncResult.error! }
        
        return asyncResult
    }
    
    @MainActor
    func getProducts() async -> [Product] {
        do {
            let products = try await Apphud.fetchProducts()
            let groups = await Apphud.permissionGroups() ?? []
//            let ids = groups.flatMap { $0.productIds }
//            let result = await Apphud.purchase(products.first!)
            print("DEBUG: Products \(products)")
            
            return products
        } catch {
            return []
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
    
    // MARK: - Debug
    
    /// Проверить подключение к AppHud
    @MainActor
    func checkApphudConnection() {
        print("\n🔌 === ПРОВЕРКА ПОДКЛЮЧЕНИЯ К APPHUD ===\n")
        
        // 1. Проверяем User ID (если есть - AppHud инициализирован)
        let userID = Apphud.userID()
        
        print("DEBUG: user id \(userID)")
    }
    /// Загрузить все группы подписок из StoreKit
    @MainActor
    func loadSubscriptionGroups() async {
        let groups = await Apphud.permissionGroups() ?? []
        let productsIds = groups.compactMap { $0.productIds }
        print("DEBUG: productsIds \(productsIds)")
        do {
            
            let allProducts = Apphud.products
            let products = try await Apphud.fetchProducts()
            print("DEBUG: products \(products)")
        } catch {
            print("DEBUG: error \(error.localizedDescription)")
        }
        
    }
    
    /// Загрузить продукты через AppHud
    func loadApphudProducts() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            
        }
    }
}
