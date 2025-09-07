//
//  ContentView.swift
//  Lumio
//
//  Created by Артур Кулик on 22.08.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject var coordinator = Coordinator()
    @StateObject var appState = AppState()
    
    var body: some View {
        switch appState.viewState {
        case .onboarding:
            OnboardingView()
                .environmentObject(appState)
        case .main:
            
            mainContent
        }
    }
    
    var mainContent: some View {
        NavigationStack(path: $coordinator.mainPath) {
            TabBarView()
                .navigationDestination(for: Screen.self) { screen in
                    coordinator.build(screen: screen)
                }
        }
    }
}

#Preview {
    MainView()
}
