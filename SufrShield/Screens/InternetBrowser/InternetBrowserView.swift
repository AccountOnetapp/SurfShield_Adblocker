//
//  InternetBrowserView.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI



struct InternetBrowserView: View {
    
    var body: some View {
        browser
    }
    
    @ViewBuilder
    var browser: some View {
        VStack {
            WebViewPanel()
            
            
            WebView(url: URL(string: "https://google.com")!)
                .frame(maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
    }
}


#Preview {
    InternetBrowserView()
}
