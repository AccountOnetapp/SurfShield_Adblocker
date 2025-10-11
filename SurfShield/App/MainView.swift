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
    @Environment(\.scenePhase) private var scenePhase
    private let appInteractor = Executor.appInteractor
    
    var body: some View {
        content
            .environmentObject(appState)
            .environmentObject(coordinator)
            .fullScreenCover(item: $coordinator.presentedScreen) { screen in
                coordinator.build(screen: screen)
            }
            .sheet(isPresented: $appState.isShowPaywall) {
                PaywallView()
            }
            .onChange(of: scenePhase) { newValue in
                Task {
                    await appInteractor.appCheck()
                }
            }
    }
    
    
    @ViewBuilder
    var content: some View {
        switch appState.viewState {
        case .splash:
            SplashScreenView()
        case .onboarding:
            OnboardingView()
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
                .onAppear {
                    if appState.isFirstLoad {
                        //MARK: Uncomment later after subscriptions implement
                        coordinator.fullScreenCover(to: .paywall)
                    }
                }
        }

    }
}

#Preview {
    MainView()
}
