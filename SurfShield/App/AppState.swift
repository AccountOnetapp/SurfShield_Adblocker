//
//  AppState.swift
//  SufrShield
//
//  Created by Артур Кулик on 07.09.2025.
//

import SwiftUI

final class AppState: ObservableObject {
    @Published var viewState: AppViewState
    var isFirstLoad: Bool = true
    private let userDefaultsService = UserDefaultsService.shared
    
    enum AppViewState {
        case onboarding
        case main
    }
    
    init() {
        let isOnboardingShown = userDefaultsService.load(Bool.self, forKey: .onboardingCompleted) ?? false
        self.viewState = isOnboardingShown ? .main : .onboarding
//        self.viewState = .onboarding
    }
    
    
    public func onboardingCompleted() {
        userDefaultsService.save(true, forKey: .onboardingCompleted)
        withAnimation(.easeIn(duration: 0.3)) {
            viewState = .main
        }
    }
    
    private func initialState() {
        let isOnboardingShown = userDefaultsService.load(Bool.self, forKey: .onboardingCompleted) ?? false
        self.viewState = isOnboardingShown ? .main : .onboarding
    }
}
