//
//  ContentView.swift
//  Lumio
//
//  Created by Артур Кулик on 22.08.2025.
//

import SwiftUI

struct MainView: View {
    @StateObject var coordinator = Coordinator()
    
    var body: some View {
        NavigationStack(path: $coordinator.mainPath) {
            TabBarView()
                .navigationDestination(for: Screen.self) { screen in
//                    coordinator.build(screen: screen)
                }
        }
    }
}

#Preview {
    MainView()
}
