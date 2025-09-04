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

class WebViewInteractor: WebViewObservables, WebViewActions, ObservableObject {
    @Published private (set)var goBack: Bool = false
    @Published private (set)var goForward: Bool = false
    @Published private(set) var url: URL = URL(string: "https://google.com")!
    @Published private(set) var canGoBack: Bool = false
    @Published private(set) var canGoForward: Bool = false
    @Published private(set) var refresh: Bool = false
    
    
    func goToUrl(string: String) {
        guard let url = URL(string: string) else {
            print("DEBUG: WRONG URL")
            return
        }
        
        self.url = url
    }
    
    func refresh(_ isRefresh: Bool) {
        self.refresh = isRefresh
    }
    
    func goBack(_ isGo: Bool) {
        self.goBack = isGo
    }
    
    func goForward(_ isGo: Bool) {
        self.goForward = isGo
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
