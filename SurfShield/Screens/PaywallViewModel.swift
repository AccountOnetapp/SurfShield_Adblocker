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
    @Published var error: Error?
    @Published var infoAlert: InfoAlert?
    
    init() {
        getProduct()
    }
    
    func purchase(isSuccess: @escaping (Bool) -> Void) {
        Task {
            do {
                let result = try await purchaseInteractor.purchase(.weekly)
                isSuccess(result)
            } catch {
                self.error = error
            }
        }
    }
    
    func restore() {
        Task {
            do {
                let result = try await purchaseInteractor.restore()
                await MainActor.run {
                    if result.isSuccess {
                        infoAlert = InfoAlert(
                            title: "Success",
                            text: result.message
                        )
                    } else {
                        infoAlert = InfoAlert(
                            title: "No Active Subscriptions",
                            text: result.message
                        )
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
    
    func getProduct() {
        Task { @MainActor in
            do {
                let product = try await purchaseInteractor.getProduct(.weekly)
                self.price = product.displayPrice
            } catch {
                self.error = error
                print("DEBUG: Error of fetch product \(error.localizedDescription)")
            }
        }
    }
}

