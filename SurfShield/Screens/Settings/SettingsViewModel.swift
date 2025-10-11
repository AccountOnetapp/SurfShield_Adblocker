//
//  SettingsViewModel.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.09.2025.
//

import Foundation
import SwiftUI
import Combine

final class SettingsViewModel: ObservableObject {
    
    let userDefaultsObserver = UserDefaultsObserver.shared
    @Published var appInteractor = Executor.appInteractor
    
    @Published var resourceStatistics: ResourceAnalysisData = .init()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupStatisticsObserver()
    }
    
    @MainActor
    public func checkPremiumAccess(showPaywall: Binding<Bool>, action: @escaping () -> Void) {
        Task {
            await appInteractor.checkPremiumAccess(showPaywall: showPaywall, action: action)
        }
    }
    
    public func openAppStore() {
        if let url = URL(string: Constants.appStoreLink) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func setupStatisticsObserver() {
        // Подписываемся на обновления статистики
        userDefaultsObserver.$webViewBlockedStatistics
            .receive(on: DispatchQueue.main)
            .assign(to: \.resourceStatistics, on: self)
            .store(in: &cancellables)
    }
}
