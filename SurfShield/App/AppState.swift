//
//  AppState.swift
//  SufrShield
//
//  Created by Артур Кулик on 07.09.2025.
//

import SwiftUI

final class AppState: ObservableObject {
    @Published var viewState: AppViewState
    private let appInteractor = Executor.appInteractor
    @Published public var isShowPaywall: Bool = false
    var isFirstLoad: Bool = true
    private let userDefaultsService = UserDefaultsService.shared
    
    enum AppViewState {
        case splash
        case onboarding
        case main
    }
    
    init() {
        let isOnboardingShown = userDefaultsService.load(Bool.self, forKey: .onboardingCompleted) ?? false
        self.isFirstLoad = userDefaultsService.load(Bool.self, forKey: .isFirstLoad) ?? true
        // Всегда начинаем с splash screen
        self.viewState = .splash
        appCheck()
    }
    
    
    public func onboardingCompleted() {
        userDefaultsService.save(true, forKey: .onboardingCompleted)
        userDefaultsService.save(false, forKey: .isFirstLoad)
        withAnimation(.easeIn(duration: 0.3)) {
            viewState = .main
        }
    }
    
    private func appCheck() {
        Task { @MainActor in
            await appInteractor.appCheck()
            let isOnboardingShown = userDefaultsService.load(Bool.self, forKey: .onboardingCompleted) ?? false
            self.isFirstLoad = userDefaultsService.load(Bool.self, forKey: .isFirstLoad) ?? true
            withAnimation(.easeIn(duration: 0.3)) {
                    self.viewState = isOnboardingShown ? .main : .onboarding
            }
        }
    }
    
    private func initialState() {
        let isOnboardingShown = userDefaultsService.load(Bool.self, forKey: .onboardingCompleted) ?? false
        self.isFirstLoad = userDefaultsService.load(Bool.self, forKey: .isFirstLoad) ?? true
        self.viewState = isOnboardingShown ? .main : .onboarding
        
    }
}
