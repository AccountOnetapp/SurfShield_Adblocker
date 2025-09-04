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
    
    var body: some View {
        VStack(spacing: 0) {
            // Панель навигации
            HStack(spacing: 12) {
                // Кнопки навигации
                HStack(spacing: 8) {
                    BrowserNavigationButton(.back, isEnabled: canGoBack, action: goBack)
                    BrowserNavigationButton(.forward, isEnabled: canGoForward, action: goForward)
                    BrowserNavigationButton(.refresh, action: refreshPage)
                }
                
                // Адресная строка
                AddressBarView(
                    urlText: $currentURL,
                    onGoAction: goToURL,
                    onClearAction: clearURL
                )
                
                // Кнопка поделиться
                BrowserNavigationButton(.share) {
                    shareAction()
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
    
    // MARK: - Actions
    private func goBack() {
        print("Назад")
        // TODO: Реализовать навигацию назад
    }
    
    private func goForward() {
        print("Вперед")
        // TODO: Реализовать навигацию вперед
    }
    
    private func refreshPage() {
        print("Обновление страницы")
        // TODO: Реализовать обновление страницы
    }
    
    private func goToURL() {
        print("Переход к URL: \(currentURL)")
        // TODO: Реализовать переход по URL
    }
    
    private func clearURL() {
        currentURL = ""
    }
    
    private func shareAction() {
        print("Sharing: \(currentURL)")
        // TODO: Реализовать функциональность поделиться
    }
}
