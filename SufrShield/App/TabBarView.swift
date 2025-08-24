//
//  TabBarView.swift
//  Lumio
//
//  Created by Артур Кулик on 22.08.2025.
//

import SwiftUI


struct TabBarView: View {
    @State var selection: Int = 0
    
    var body: some View {
        content
    }
    
    var content: some View {
        tabView
    }
    
    
    var tabView: some View {
        TabView(selection: $selection,
                content:  {
            BlockAdsView()
                .tabItem { Label("Block Ads", systemImage: "flame.fill") }
                .tag(0)
            
            Text("Hello surf shield Second View")
                .tabItem { Label("Settings", systemImage: "gear") }
                .tag(0)
        }
        )
        .tint(.tm.accentSecondary)
    }
}
