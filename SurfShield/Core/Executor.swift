//
//  Executor.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.10.2025.
//

import Foundation

class Executor {
    static private let container = DIContainer()
    
    static var purchaseInteractor: PurchaseRepository {
        return container.purchaseInteractor
    }
    
    static var appInteractor: AppInteractor {
        return container.appInteractor
    }
}
