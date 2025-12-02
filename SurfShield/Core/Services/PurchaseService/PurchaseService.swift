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
    // ID приходит из Purchase Interactor из энума SubscriptionType
    func purchase(id: String) async throws -> ApphudAsyncPurchaseResult {
        print("\n💳 === НАЧАЛО ПОКУПКИ ===\n")
        print("DEBUG: Покупаем подписку с ID: \(id)")
        
        do {
            let product = try await getProduct(id: id)
            print("DEBUG: Продукт найден: \(product.displayName) - \(product.displayPrice)")
            
            let asyncResult = await Apphud.purchase(product)
            
            print("DEBUG: Результат покупки:")
            print("  - Success: \(asyncResult.success)")
            print("  - Error: \(asyncResult.error?.localizedDescription ?? "nil")")
            print("  - Subscription: \(asyncResult.subscription?.productId ?? "nil")")
            
            guard asyncResult.error == nil else { 
                print("❌ Ошибка покупки: \(asyncResult.error!.localizedDescription)")
                throw asyncResult.error! 
            }
            
            print("✅ Покупка успешна!")
            print("\n💳 === КОНЕЦ ПОКУПКИ ===\n")
            
            return asyncResult
        } catch {
            print("❌ DEBUG: purchase error \(error.localizedDescription)")
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
    /// Восстановить покупки
    private func restorePurchases() async throws -> [ApphudSubscription] {
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
    // MARK: - Status
    @MainActor
    /// Проверить активную подписку
    func hasActiveSubscription() async -> Bool {
        let debugDisableSubscription = false
        #if DEBUG
        if debugDisableSubscription {
            return false
        }
        #endif
        
        // Детальная отладка статуса подписки
        print("\n🔍 === ПРОВЕРКА СТАТУСА ПОДПИСКИ ===\n")
        
        let userID = Apphud.userID()
        print("DEBUG: AppHud User ID: \(userID)")
        
        let hasActive = Apphud.hasActiveSubscription()
        print("DEBUG: hasActiveSubscription(): \(hasActive)")
        
        let subscription = Apphud.subscription()
        print("DEBUG: Current subscription: \(subscription?.productId ?? "nil")")
        print("DEBUG: Subscription status: \(subscription?.status.rawValue ?? "nil")")
        print("DEBUG: Subscription isActive: \(subscription?.isActive() ?? false)")
        
        let allSubscriptions = Apphud.subscriptions() ?? []
        print("DEBUG: All subscriptions count: \(allSubscriptions.count)")
        for (index, sub) in allSubscriptions.enumerated() {
            print("DEBUG: Subscription \(index): \(sub.productId) - \(sub.status.rawValue) - Active: \(sub.isActive())")
        }
        
        // Проверяем через StoreKit напрямую (самая надежная проверка)
        let storeKitHasActive = await checkStoreKitSubscription()
        print("DEBUG: StoreKit hasActive: \(storeKitHasActive)")
        
        // Проверяем все подписки напрямую
        let hasActiveSubscriptions = allSubscriptions.contains { $0.isActive() }
        print("DEBUG: Any subscription isActive(): \(hasActiveSubscriptions)")
        
        // Используем максимально надежную проверку для продакшена
        // StoreKit - самый надежный источник истины
        let finalResult = storeKitHasActive || hasActive || hasActiveSubscriptions
        print("DEBUG: Final result (StoreKit || AppHud || Subscriptions): \(finalResult)")
        
        print("\n🔍 === КОНЕЦ ПРОВЕРКИ СТАТУСА ===\n")
        
        return finalResult
    }
    
    /// Проверка подписки через StoreKit напрямую (максимально надежная для продакшена)
    @MainActor
    private func checkStoreKitSubscription() async -> Bool {
        print("DEBUG: === ПРОВЕРКА STOREKIT ===")
        
        do {
            // 1. Проверяем активные транзакции (самый надежный способ)
            var hasActiveTransaction = false
            var activeTransactions: [String] = []
            
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    let isActive = transaction.revocationDate == nil
                    print("DEBUG: Transaction \(transaction.productID): \(isActive ? "ACTIVE" : "REVOKED")")
                    
                    if isActive {
                        hasActiveTransaction = true
                        activeTransactions.append(transaction.productID)
                    }
                }
            }
            
            print("DEBUG: Active transactions: \(activeTransactions)")
            print("DEBUG: Has active transaction: \(hasActiveTransaction)")
            
            // 2. Дополнительная проверка через продукты
            let products = try await Apphud.fetchProducts()
            print("DEBUG: StoreKit products count: \(products.count)")
            
            var hasSubscriptionProduct = false
            for product in products {
                if let subscription = product.subscription {
                    print("DEBUG: Subscription product: \(product.id) - \(product.displayPrice)")
                    print("DEBUG: Subscription period: \(subscription.subscriptionPeriod)")
                    hasSubscriptionProduct = true
                }
            }
            
            print("DEBUG: Has subscription products: \(hasSubscriptionProduct)")
            
            // 3. Финальный результат
            let result = hasActiveTransaction
            print("DEBUG: StoreKit final result: \(result)")
            print("DEBUG: === КОНЕЦ ПРОВЕРКИ STOREKIT ===")
            
            return result
            
        } catch {
            print("❌ DEBUG: StoreKit check error: \(error.localizedDescription)")
            print("DEBUG: === КОНЕЦ ПРОВЕРКИ STOREKIT (ERROR) ===")
            return false
        }
    }
    
    @MainActor
    /// Получить текущую подписку
    func getSubscription() -> ApphudSubscription? {
        return Apphud.subscription()
    }
    
    /// Альтернативная проверка активной подписки (более надежная)
    @MainActor
    func hasActiveSubscriptionAlternative() async -> Bool {
        print("\n🔄 === АЛЬТЕРНАТИВНАЯ ПРОВЕРКА ПОДПИСКИ ===\n")
        
        // 1. Проверяем статус без синхронизации
        print("DEBUG: Проверка без синхронизации")
        
        // 2. Проверяем через AppHud
        let apphudActive = Apphud.hasActiveSubscription()
        print("DEBUG: AppHud hasActive: \(apphudActive)")
        
        // 3. Проверяем через StoreKit напрямую
        let storeKitActive = await checkStoreKitSubscription()
        print("DEBUG: StoreKit hasActive: \(storeKitActive)")
        
        // 4. Проверяем все подписки
        let subscriptions = Apphud.subscriptions() ?? []
        let hasActiveSub = subscriptions.contains { $0.isActive() }
        print("DEBUG: Any subscription active: \(hasActiveSub)")
        
        // Возвращаем true если хотя бы один метод показывает активную подписку
        let result = apphudActive || storeKitActive || hasActiveSub
        print("DEBUG: Final result: \(result)")
        
        print("\n🔄 === КОНЕЦ АЛЬТЕРНАТИВНОЙ ПРОВЕРКИ ===\n")
        
        return result
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
}
