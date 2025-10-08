//
//  PurchaseInteractor.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import Foundation
import SwiftUI
import ApphudSDK

class PurchaseInteractor {
    //TODO: Implement PurchaseService
    var purchaseService: PurchaseService
    
    init(purchaseService: PurchaseService) {
        self.purchaseService = purchaseService
    }
    
    
    
    /// Проверить премиум доступ и выполнить действие или показать paywall
    /// - Parameters:
    ///   - showPaywall: Binding для отображения paywall
    ///   - action: Действие, которое выполнится при наличии подписки
    @MainActor
    func checkPremiumAccess(showPaywall: Binding<Bool>, action: @escaping () -> Void) async {
        let hasPremium = purchaseService.hasActiveSubscription()
        
        if hasPremium {
            // Есть подписка - выполняем действие
            action()
        } else {
            // Нет подписки - показываем paywall
            showPaywall.wrappedValue = true
        }
    }
}
