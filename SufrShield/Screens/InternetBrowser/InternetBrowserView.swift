//
//  InternetBrowserView.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI

struct InternetBrowserView: View {
    @State private var currentURL = "https://apple.com"
    @State private var webViewContainer: WebViewContainer?
    
    var body: some View {
        VStack(spacing: 0) {
            // Адресная строка
            AddressBar(
                url: $currentURL,
                onGo: {
                    loadURL()
                },
                onRefresh: {
                    webViewContainer?.reload()
                }
            )
            
            // Панель навигации
            NavigationBar(
                canGoBack: webViewContainer?.canGoBack ?? false,
                canGoForward: webViewContainer?.canGoForward ?? false,
                onBack: {
                    webViewContainer?.goBack()
                },
                onForward: {
                    webViewContainer?.goForward()
                },
                onHome: {
                    currentURL = "https://apple.com"
                    loadURL()
                },
                onShare: {
                    shareCurrentPage()
                }
            )
            
            // WebView контейнер
            if let container = webViewContainer {
                container
            } else {
                // Показываем загрузку только при первом запуске
                ProgressView("Инициализация браузера...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            // Создаем контейнер только один раз при появлении экрана
            if webViewContainer == nil {
                webViewContainer = WebViewContainer(url: URL(string: currentURL)!)
            }
        }
    }
    
    private func loadURL() {
        // Валидация URL
        guard let url = URL(string: currentURL) else {
            // Если URL невалидный, добавляем https://
            if !currentURL.hasPrefix("http://") && !currentURL.hasPrefix("https://") {
                currentURL = "https://" + currentURL
            }
            return
        }
        
        // Обновляем URL в существующем контейнере
        webViewContainer?.loadURL(url)
    }
    
    private func shareCurrentPage() {
        // Логика для поделиться страницей
        print("Sharing: \(currentURL)")
    }
}
