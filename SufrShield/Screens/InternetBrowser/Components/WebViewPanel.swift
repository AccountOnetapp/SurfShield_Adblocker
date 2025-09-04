//
//  WebViewPanel.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI

struct WebViewPanel: View {
    @State private var currentURL = "https://google.com"
    
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
    
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Панель навигации
            HStack(spacing: 12) {
                // Кнопки навигации (скрываются при фокусе адресной строки)
                if !isFocused {
                    HStack(spacing: 8) {
                        BrowserNavigationButton(.back, isEnabled: observables.canGoBack, action: onGoBack)
                        BrowserNavigationButton(.forward, isEnabled: observables.canGoForward, action: onGoForward)
                        BrowserNavigationButton(.refresh, action: onRefresh)
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
                }
                
                // Адресная строка (расширяется при скрытии кнопок)
                AddressBarView(
                    urlText: $currentURL,
                    onGoAction: {
                        onGoToURL(currentURL)
                    }
                )
                .focused($isFocused)
                
                // Кнопка поделиться (скрывается при фокусе адресной строки)
                if !isFocused {
                    BrowserNavigationButton(.share) {
                        onShare(currentURL)
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.8).combined(with: .opacity)
                    ))
                }
            }
            .animation(.easeOut(duration: 0.3), value: isFocused)
            .clipped()
            .padding(.horizontal, .regular)
            .padding(.vertical, .regular)
            .background(.ultraThinMaterial)
            .shadow(
                color: .black.opacity(0.1),
                radius: 8,
                x: 0,
                y: 4
            )
            .shadow(
                color: .black.opacity(0.05),
                radius: 2,
                x: 0,
                y: 1
            )
            
//            // Индикатор загрузки
//            if isLoading {
//                ProgressView(value: progress)
//                    .progressViewStyle(LinearProgressViewStyle())
//                    .frame(height: 2)
//            }
        }
    }
}
