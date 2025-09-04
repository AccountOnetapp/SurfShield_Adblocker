//
//  WebViewPanel.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI

struct WebViewPanel: View {
    @State private var currentURL = "https://google.com"
    @State private var canGoBack = false
    @State private var canGoForward = false
    @State private var isLoading = false
    @State private var progress: Double = 0.0
    
    var observables: WebViewObservables
    // Closures для внешних действий
    let onGoBack: () -> Void
    let onGoForward: () -> Void
    let onRefresh: () -> Void
    let onGoToURL: (String) -> Void
    let onShare: (String) -> Void
    
    init(
        observables: WebViewObservables,
        onGoBack: @escaping () -> Void = {},
        onGoForward: @escaping () -> Void = {},
        onRefresh: @escaping () -> Void = {},
        onGoToURL: @escaping (String) -> Void = { _ in },
        onShare: @escaping (String) -> Void = { _ in }
    ) {
        self.observables = observables
        self.onGoBack = onGoBack
        self.onGoForward = onGoForward
        self.onRefresh = onRefresh
        self.onGoToURL = onGoToURL
        self.onShare = onShare
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Панель навигации
            HStack(spacing: 12) {
                // Кнопки навигации
                HStack(spacing: 8) {
                    BrowserNavigationButton(.back, isEnabled: canGoBack, action: onGoBack)
                    BrowserNavigationButton(.forward, isEnabled: canGoForward, action: onGoForward)
                    BrowserNavigationButton(.refresh, action: onRefresh)
                }
                
                // Адресная строка
                AddressBarView(
                    urlText: $currentURL,
                    onGoAction: {
                        onGoToURL(currentURL)
                    }
                )
                
                // Кнопка поделиться
                BrowserNavigationButton(.share) {
                    onShare(currentURL)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            // Индикатор загрузки
            if isLoading {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .frame(height: 2)
            }
        }
    }
}
