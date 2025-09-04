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
//        webView.scrollView.contentInset = .init(top: 55, left: .zero, bottom: .zero, right: .zero)
        webView.clipsToBounds = false
        webView.layer.masksToBounds = false
        webView.scrollView.clipsToBounds = false
        webView.scrollView.layer.masksToBounds = false
        
        context.coordinator.webView = webView
        webView.navigationDelegate = context.coordinator
        
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
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Обновляем состояние навигации при завершении загрузки
            parent?.interactor.setCanGoBack(webView.canGoBack)
            parent?.interactor.setCanGoForward(webView.canGoForward)
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            // Обновляем состояние навигации при начале загрузки
            parent?.interactor.setCanGoBack(webView.canGoBack)
            parent?.interactor.setCanGoForward(webView.canGoForward)
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


