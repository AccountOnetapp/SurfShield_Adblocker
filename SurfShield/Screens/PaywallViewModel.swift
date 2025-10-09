//
//  PaywallViewModel.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import Foundation

final class PaywallViewModel: ObservableObject {
    let purchaseInteractor: PurchaseInteractor = Executor.purchaseInteractor
    
    func purchase(isSuccess: @escaping (Bool) -> Void) {
        Task {
            let result = await purchaseInteractor.purchase(.weekly)
            isSuccess(result)
        }
    }
}
