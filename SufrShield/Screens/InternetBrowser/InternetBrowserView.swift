//
//  InternetBrowserView.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI



struct InternetBrowserView: View {
    @StateObject var interactor = WebViewInteractor()
    
    var body: some View {
        browser
    }
    
    @ViewBuilder
    var browser: some View {
        VStack {
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
            
            WebView(interactor: interactor)
                .frame(maxHeight: .infinity)
        }
        .frame(maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.light)
    }
}


#Preview {
    InternetBrowserView()
}
