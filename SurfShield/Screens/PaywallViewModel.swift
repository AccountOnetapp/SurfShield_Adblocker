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
    @Published var isLoading: Bool = false
    
    init() {
        getProduct()
    }
    
    func purchase(isSuccess: @escaping (Bool) -> Void) {
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                let result = try await purchaseInteractor.purchase(.weekly)
                
                await MainActor.run {
                    isLoading = false
                    isSuccess(result)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    self.error = error
                }
            }
        }
    }
    
    func restore() {
        Task {
            await MainActor.run {
                isLoading = true
            }
            
            do {
                let result = try await purchaseInteractor.restore()
                await MainActor.run {
                    isLoading = false
                    
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
                    isLoading = false
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

