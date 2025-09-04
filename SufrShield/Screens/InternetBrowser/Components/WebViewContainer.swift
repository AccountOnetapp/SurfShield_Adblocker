//
//  WebViewContainer.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI
import WebKit

struct WebViewContainer: View {
    @State var isLoading = false
    @State var errorMessage: String?
    @State var canGoBack = false
    @State var canGoForward = false
    @State var currentURL = ""
    @State var webView: WKWebView?
    
    let initialURL: URL
    
    init(url: URL) {
        self.initialURL = url
    }
    
    var body: some View {
        ZStack {
            // WebView
            WebViewWrapper(
                initialURL: initialURL,
                isLoading: $isLoading,
                errorMessage: $errorMessage,
                canGoBack: $canGoBack,
                canGoForward: $canGoForward,
                currentURL: $currentURL,
                webView: $webView
            )
            
            // Индикатор загрузки
            if isLoading {
                LoadingOverlay()
            }
            
            // Сообщение об ошибке
            if let errorMessage = errorMessage {
                ErrorOverlay(errorMessage: errorMessage) {
                    self.errorMessage = nil
                    // Перезагружаем страницу
                    webView?.reload()
                }
            }
        }
    }
    
    // Методы для управления навигацией
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
    
    func reload() {
        webView?.reload()
    }
    
    func goHome() {
        let request = URLRequest(url: initialURL)
        webView?.load(request)
    }
    
    func loadURL(_ url: URL) {
        let request = URLRequest(url: url)
        webView?.load(request)
    }
}

// Обертка для WebView, которая не пересоздается
struct WebViewWrapper: UIViewRepresentable {
    let initialURL: URL
    @Binding var isLoading: Bool
    @Binding var errorMessage: String?
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool
    @Binding var currentURL: String
    @Binding var webView: WKWebView?
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        self.webView = webView
        
        // Загружаем начальный URL
        let request = URLRequest(url: initialURL)
        webView.load(request)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // Не пересоздаем WebView, только обновляем состояния
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebViewWrapper
        
        init(_ parent: WebViewWrapper) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.isLoading = true
            parent.errorMessage = nil
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.isLoading = false
            parent.canGoBack = webView.canGoBack
            parent.canGoForward = webView.canGoForward
            parent.currentURL = webView.url?.absoluteString ?? ""
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.isLoading = false
            parent.errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    WebViewContainer(url: URL(string: "https://apple.com")!)
}
