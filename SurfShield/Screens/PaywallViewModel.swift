//
//  PaywallViewModel.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import Foundation

final class PaywallViewModel: ObservableObject {
    let purchaseInteractor: PurchaseRepository = Executor.purchaseRepository
    @Published var price: String = ""
    
    
    init() {
        getProduct()
    }
    
    func purchase(isSuccess: @escaping (Bool) -> Void) {
        Task {
            let result = await purchaseInteractor.purchase(.weekly)
            isSuccess(result)
        }
    }
    
    func getProduct() {
        Task { @MainActor in
            do {
                let product = try await purchaseInteractor.getProduct(.weekly)
                self.price = product.displayPrice
            } catch {
                
                print("DEBUG: Error of fetch product \(error.localizedDescription)")
            }
        }
    }
}

