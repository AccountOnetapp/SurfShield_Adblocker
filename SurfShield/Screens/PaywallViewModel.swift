//
//  PaywallViewModel.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import Foundation

final class PaywallViewModel: ObservableObject {
    let purchaseInteractor: PurchaseInteractor = Executor.purchaseInteractor
    
    func purchase() {
        Task {
            await purchaseInteractor.purchase(.weekly)
        }
    }
}
