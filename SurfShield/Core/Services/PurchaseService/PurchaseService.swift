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

enum PurchaseError: Error, LocalizedError {
    case noProducts
    case noProductWithThisId
    case purchaseFailed
    case restoreFailed
    case cancelled
    
    /// Human-readable error description
    var description: String {
        switch self {
        case .noProducts:
            return "Failed to load products from App Store"
        case .noProductWithThisId:
            return "Failed to find subscription"
        case .purchaseFailed:
            return "Failed to complete purchase"
        case .restoreFailed:
            return "Failed to restore purchases"
        case .cancelled:
            return "Purchase cancelled by user"
        }
    }
    
    /// Localized error description (for system alerts)
    var errorDescription: String? {
        return description
    }
    
    /// Error name for analytics
    var analyticsName: String {
        switch self {
        case .noProducts: return "no_products"
        case .noProductWithThisId: return "product_not_found"
        case .purchaseFailed: return "purchase_failed"
        case .restoreFailed: return "restore_failed"
        case .cancelled: return "purchase_cancelled"
        }
    }
}

// MARK: - Result

struct PurchaseResult {
    let subscription: ApphudSubscription?
    let isSuccess: Bool
    let error: Error?
}

struct RestoreResult {
    let subscriptions: [ApphudSubscription]
    let isSuccess: Bool
    let message: String
    
    var hasActiveSubscriptions: Bool {
        subscriptions.contains { $0.isActive() }
    }
    
    var activeCount: Int {
        subscriptions.filter { $0.isActive() }.count
    }
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
        do {
            let product = try await getProduct(id: id)
            let asyncResult = await Apphud.purchase(product)
            
            guard asyncResult.error == nil else { throw asyncResult.error! }
            return asyncResult
        } catch {
            print("DEBUG: purchase error \(error.localizedDescription)")
            throw PurchaseError.noProducts
        }
    }
    
    @MainActor
    /// Восстановить покупки и вернуть результат
    func restore() async throws -> RestoreResult {
        do {
            let subscriptions = try await restorePurchases()
            
            // Проверяем, есть ли активные подписки
            let activeSubscriptions = subscriptions.filter { $0.isActive() }
            
            if !activeSubscriptions.isEmpty {
                print("✅ Restored \(activeSubscriptions.count) active subscription(s)")
                return RestoreResult(
                    subscriptions: activeSubscriptions,
                    isSuccess: true,
                    message: "Successfully restored \(activeSubscriptions.count) subscription(s)"
                )
            } else if !subscriptions.isEmpty {
                // Есть подписки, но они неактивны
                print("⚠️ Found subscriptions but none are active")
                return RestoreResult(
                    subscriptions: subscriptions,
                    isSuccess: false,
                    message: "No active subscriptions found"
                )
            } else {
                // Подписок вообще нет
                print("ℹ️ No subscriptions to restore")
                return RestoreResult(
                    subscriptions: [],
                    isSuccess: false,
                    message: "No purchases to restore"
                )
            }
        } catch {
            print("❌ Restore failed: \(error.localizedDescription)")
            throw PurchaseError.restoreFailed
        }
    }
    
    @MainActor
    func getProducts() async -> [Product] {
        do {
            let products = try await Apphud.fetchProducts()
            return products
        } catch {
            return []
        }
    }
    
    func getProduct(id: String) async throws -> Product {
        do {
            let products = try await Apphud.fetchProducts()
            let product = products.first { $0.id == id }
            if let product {
                return product
            } else {
                throw PurchaseError.noProductWithThisId
            }
        } catch {
            throw error
        }
    }
    
    // MARK: - Paywalls
    /// Загрузить paywalls с сервера (асинхронно)
    @MainActor
    func fetchPaywalls() async -> [ApphudPaywall] {
        await withCheckedContinuation { continuation in
            Apphud.paywallsDidLoadCallback { paywalls, error in
                if let error = error {
                    print("❌ Ошибка загрузки paywalls: \(error)")
                    continuation.resume(returning: [])
                } else {
                    continuation.resume(returning: paywalls)
                }
            }
        }
    }
    
    /// Получить все продукты из всех paywalls
    @MainActor
    func getAllProductsFromPaywalls() async -> [ApphudProduct] {
        let paywalls = await fetchPaywalls()
        return paywalls.flatMap { $0.products }
    }

    
    @MainActor
    /// Восстановить покупки
    func restorePurchases() async throws -> [ApphudSubscription] {
        try await withCheckedThrowingContinuation { continuation in
            Apphud.restorePurchases { subscriptions, _, error in
                if error != nil {
                    continuation.resume(throwing: error!)
                } else {
                    continuation.resume(returning: subscriptions ?? [])
                }
            }
        }
    }
    
    // MARK: - Status
    
    /// Проверить активную подписку
    func hasActiveSubscription() -> Bool {
        let debugDisableSubscription = true
        #if DEBUG
        if debugDisableSubscription {
            return false
        }
        #endif
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
