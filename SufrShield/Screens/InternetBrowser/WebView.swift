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
        context.coordinator.webView = webView
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Загружаем новую страницу, если URL изменился
        if uiView.url != interactor.url {
            uiView.load(URLRequest(url: interactor.url))
        }
        
        if interactor.goBack {
            if uiView.canGoBack {
                uiView.goBack()
            }
            interactor.goBack(false)
        }
        
        if interactor.goForward {
            if uiView.canGoForward {
                uiView.goForward()
            }
            interactor.goForward(false)
        }
        
        if interactor.refresh {
            uiView.reload()
            interactor.refresh(false)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView?
        weak var webView: WKWebView?
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        // Можно здесь передавать события в interactor по необходимости
    }
}
