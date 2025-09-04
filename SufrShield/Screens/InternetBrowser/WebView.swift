//
//  WebView.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @ObservedObject var interactor: WebViewInteractor
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        
        // Настройки для корректного взаимодействия с элементами страницы
        webView.isUserInteractionEnabled = true
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.scrollView.bounces = false
        webView.scrollView.keyboardDismissMode = .interactive
        
        // Убираем проблемные настройки, которые могут блокировать касания
        webView.clipsToBounds = false
        webView.layer.masksToBounds = false
        webView.scrollView.clipsToBounds = false
        webView.scrollView.layer.masksToBounds = false
        
        // Настройки для лучшей производительности и взаимодействия
        webView.configuration.allowsInlineMediaPlayback = false
        webView.configuration.mediaTypesRequiringUserActionForPlayback = [.all]
        
        context.coordinator.webView = webView
        webView.navigationDelegate = context.coordinator
        
        webView.load(URLRequest(url: interactor.url))
        // Добавляем наблюдатели для отслеживания состояния навигации
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.canGoBack), options: [.new], context: nil)
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.canGoForward), options: [.new], context: nil)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        // Удаляем наблюдатели при уничтожении view
        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.canGoBack))
        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.canGoForward))
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WebViewNavigationDelegate {
        var parent: WebView?
        weak var webView: WKWebView?
        
        init(_ parent: WebView) {
            self.parent = parent
            super.init()
            self.parent?.interactor.navigationDelegate = self
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("DEBUG: Начало загрузки страницы")
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            // Обновляем состояние навигации при начале загрузки
            parent?.interactor.setCanGoBack(webView.canGoBack)
            parent?.interactor.setCanGoForward(webView.canGoForward)
            print("DEBUG: Загрузка страницы началась")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Обновляем состояние навигации при завершении загрузки
            parent?.interactor.setCanGoBack(webView.canGoBack)
            parent?.interactor.setCanGoForward(webView.canGoForward)
            print("DEBUG: Загрузка страницы завершена")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("DEBUG: Ошибка загрузки страницы: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Разрешаем все навигационные действия для корректной работы ссылок
            decisionHandler(.allow)
        }
        
        // MARK: - KVO Observer
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard let webView = webView else { return }
            if keyPath == #keyPath(WKWebView.canGoBack) {
                parent?.interactor.setCanGoBack(webView.canGoBack)
            } else if keyPath == #keyPath(WKWebView.canGoForward) {
                parent?.interactor.setCanGoForward(webView.canGoForward)
            }
        }
        
        func goBack() {
            webView?.goBack()
        }
        
        func goForward() {
            webView?.goForward()
        }
        
        func reload() {
            webView?.reload()
        }
        
        func loadURL(_ url: URL) {
            webView?.load(URLRequest(url: url))
        }
    }
}


