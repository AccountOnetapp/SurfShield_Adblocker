//
//  WebViewInteractor.swift
//  SufrShield
//
//  Created by Артур Кулик on 04.09.2025.
//

import Foundation

protocol WebViewObservables {
    var url: URL { get }
    var canGoBack: Bool { get }
    var goBack: Bool { get }
    var canGoForward: Bool { get }
    var goForward: Bool { get }
    var refresh: Bool { get }
}

protocol WebViewActions {
    func setCanGoBack(_ isAvailable: Bool)
    func setCanGoForward(_ isAvailable: Bool)
}

protocol WebViewNavigationDelegate: AnyObject {
    func goBack()
    func goForward()
    func reload()
    func loadURL(_ url: URL)
}


class WebViewInteractor: WebViewObservables, WebViewActions, ObservableObject {
    @Published private (set)var goBack: Bool = false
    @Published private (set)var goForward: Bool = false
    @Published private (set) var url: URL = URL(string: "https://google.com")!
    @Published private (set) var canGoBack: Bool = false
    @Published private (set) var canGoForward: Bool = false
    @Published private (set) var refresh: Bool = false
    
    weak var navigationDelegate: WebViewNavigationDelegate?
    
    func goToUrl(string: String) {
        let processedURLString = processURLString(string)
        
        guard let url = URL(string: processedURLString) else {
            print("DEBUG: WRONG URL: \(processedURLString)")
            return
        }
        
        navigationDelegate?.loadURL(url)
    }
    
    private func processURLString(_ input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Если строка пустая, возвращаем поисковую страницу
        if trimmed.isEmpty {
            return "https://google.com"
        }
        
        // Если уже есть протокол, возвращаем как есть
        if trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://") {
            return trimmed
        }
        
        // Если это IP адрес (содержит только цифры, точки и двоеточия)
        if trimmed.range(of: #"^\d+\.\d+\.\d+\.\d+(:\d+)?$"#, options: .regularExpression) != nil {
            return "http://\(trimmed)"
        }
        
        // Если содержит точку (вероятно домен), добавляем https://
        if trimmed.contains(".") {
            return "https://\(trimmed)"
        }
        
        // Если не содержит точку, считаем поисковым запросом
        let encodedQuery = trimmed.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmed
        return "https://google.com/search?q=\(encodedQuery)"
    }
    
    func refreshPage() {
        navigationDelegate?.reload()
    }
    
    func goBack(_ isGo: Bool) {
        navigationDelegate?.goBack()
    }
    
    func goForward(_ isGo: Bool) {
        navigationDelegate?.goForward()
    }
    
    func setCanGoBack(_ isAvailable: Bool) {
        self.canGoBack = isAvailable
    }
    
    func setCanGoForward(_ isAvailable: Bool) {
        self.canGoForward = isAvailable
    }
    
    func resetCommands() {
        canGoBack = false
        canGoForward = false
        refresh = false
    }
}
