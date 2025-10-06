//
//  InternetBrowserView.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI

struct InternetBrowserView: View {
    @StateObject var interactor = WebViewInteractor()
    @State private var showShareSheet = false
    
    private let panelHeight: CGFloat = 56
    
    var body: some View {
        browser
    }
    
    @ViewBuilder
    var browser: some View {
        ZStack(alignment: .top) {
            // WebView занимает весь экран
            WebView(interactor: interactor)
                .padding(.top, panelHeight)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            // Панель навигации поверх WebView
            WebViewPanel(
                observables: interactor,
                onGoBack: {
                    interactor.goBack(true)
                },
                onGoForward: {
                    interactor.goForward(true)
                },
                onRefresh: {
                    interactor.refreshPage()
                },
                onGoToURL: { url in
                    interactor.goToUrl(string: url)
                },
                onShare: { url in
                    showShareSheet = true
                }
            )
            .zIndex(1) // Панель всегда поверх WebView
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(activityItems: [interactor.url])
        }
    }
    
    
}

// MARK: - ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Ничего не нужно обновлять
    }
}

#Preview {
    InternetBrowserView()
}
