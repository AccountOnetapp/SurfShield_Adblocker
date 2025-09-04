//
//  InternetBrowserView.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI



struct InternetBrowserView: View {
    @StateObject var interactor = WebViewInteractor()
    
    private let panelHeight: CGFloat = 54
    
    var body: some View {
        browser
    }
    
    @ViewBuilder
    var browser: some View {
        WebView(interactor: interactor)
            .overlay(alignment: .top) {
                WebViewPanel(
                    observables: interactor,
                    onGoBack: {
                        print("Назад")
                        // TODO: Реализовать навигацию назад
                    },
                    onGoForward: {
                        print("Вперед")
                        // TODO: Реализовать навигацию вперед
                    },
                    onRefresh: {
                        print("Обновление страницы")
                        // TODO: Реализовать обновление страницы
                    },
                    onGoToURL: { url in
                        interactor.goToUrl(string: url)
                        print("Переход к URL: \(url)")
                        // TODO: Реализовать переход по URL
                    },
                    onShare: { url in
                        print("Sharing: \(url)")
                        // TODO: Реализовать функциональность поделиться
                    }
                )
            }
    }
    
}


#Preview {
    InternetBrowserView()
}
