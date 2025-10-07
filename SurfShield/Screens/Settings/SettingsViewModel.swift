//
//  SettingsViewModel.swift
//  SurfShield
//
//  Created by Артур Кулик on 08.09.2025.
//

import Foundation
import UIKit
import Combine

final class SettingsViewModel: ObservableObject {
    
    let userDefaultsObserver = UserDefaultsObserver.shared
    
    @Published var resourceStatistics: ResourceAnalysisData = .init()
    @Published var appSettings: AppSettings = .default {
        didSet {
            userDefaultsObserver.updateAppSettings(appSettings)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        initialState()
        subscribe()
    }
    
    public func openAppStore() {
        if let url = URL(string: Constants.appStoreLink) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
    }
    
    private func initialState() {
        appSettings = userDefaultsObserver.appSettings
    }
    
    private func subscribe() {
        userDefaultsObserver.$webViewBlockedStatistics
            .receive(on: DispatchQueue.main)
            .assign(to: \.resourceStatistics, on: self)
            .store(in: &cancellables)
    }
}
