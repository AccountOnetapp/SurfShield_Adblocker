//
//  WebView.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import SwiftUI
import WebKit
import Combine

struct WebView: UIViewRepresentable {
    @ObservedObject var interactor: WebViewInteractor
    
    var cancellable = Set<AnyCancellable>()
    
    func makeUIView(context: Context) -> WKWebView {
        // Создаем конфигурацию с предустановленным скриптом
        let config = WKWebViewConfiguration()
        
        let webView = WKWebView(frame: .zero, configuration: config)
        
        // Настройки для корректного взаимодействия с элементами страницы
        webView.isUserInteractionEnabled = true
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
//        webView.scrollView.bounces = false
        webView.scrollView.keyboardDismissMode = .interactive
        // Убираем проблемные настройки, которые могут блокировать касания
        webView.clipsToBounds = false
        webView.layer.masksToBounds = false
        webView.scrollView.clipsToBounds = false
        webView.scrollView.layer.masksToBounds = false
        
        // Настройки для лучшей производительности и взаимодействия
        webView.configuration.allowsInlineMediaPlayback = true
        webView.configuration.mediaTypesRequiringUserActionForPlayback = [.video]
        webView.setAllMediaPlaybackSuspended(true)
        
        context.coordinator.webView = webView
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        
        // Настраиваем мониторинг ресурсов после создания webView
        context.coordinator.setupResourceMonitoring()
        
        // Устанавливаем автоматическое определение темы
//        webView.overrideUserInterfaceStyle = .unspecified
        
        // Устанавливаем черный фон для WebView
        webView.backgroundColor = UIColor(named: "Container")
        webView.isOpaque = true
        webView.scrollView.backgroundColor = UIColor(named: "Container")
        
        // Применяем тему немедленно при создании WebView
        let isDarkMode = interactor.appInteractor.appSettings.enableBrowserDarkMode
        if isDarkMode {
            DispatchQueue.main.async {
                webView.evaluateJavaScript(interactor.darkThemeScript) { result, error in
                    if let error = error {
                        print("❌ Ошибка применения темы: \(error)")
                    } else {
                        print("✅ Тема применена немедленно при создании WebView")
                    }
                }
            }
        }
        
        webView.load(URLRequest(url: interactor.url))
        // Добавляем наблюдатели для отслеживания состояния навигации
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.url), options: [.new], context: nil)
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.canGoBack), options: [.new], context: nil)
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.canGoForward), options: [.new], context: nil)
        webView.addObserver(context.coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: [.new], context: nil)
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    fileprivate func applyTheme(_ config: WKWebViewConfiguration) {
        // Применяем тему статически при создании WebView для предотвращения мигания
        let isDarkMode = interactor.appInteractor.appSettings.enableBrowserDarkMode
        
        if isDarkMode {
            let darkThemeScript = interactor.darkThemeScript
            let userDarkThemeScript = WKUserScript(
                source: darkThemeScript,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            )
            config.userContentController.addUserScript(userDarkThemeScript)
        }
    }
    
    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        // Удаляем наблюдатели при уничтожении view
        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.url))
        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.canGoBack))
        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.canGoForward))
        uiView.removeObserver(coordinator, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    
    //MARK: - Coordinator
    class Coordinator: NSObject, WKNavigationDelegate, WebViewNavigationDelegate, WKUIDelegate {
        var parent: WebView?
        weak var webView: WKWebView?
        var cancellable = Set<AnyCancellable>()
        
        init(_ parent: WebView) {
            self.parent = parent
            super.init()
            self.parent?.interactor.navigationDelegate = self
            self.addedContentRules()
            subscribe()
        }
        
        func subscribe() {
            parent?.interactor.appInteractor.$appSettings.sink(receiveValue: { [weak self] settings in
                print("Debug: Settings updated \(settings.enableBrowserDarkMode)")
                self?.applyTheme(isDarkMode: settings.enableBrowserDarkMode)
            })
            .store(in: &cancellable)
        }

        private func applyTheme(isDarkMode: Bool) {
            guard let webView = webView else { return }
            
            if isDarkMode {
                // Применяем темную тему
                let darkThemeScript = parent?.interactor.darkThemeScript ?? ""
                webView.evaluateJavaScript(darkThemeScript) { result, error in
                    if let error = error {
                        print("❌ DEBUG: Theme Ошибка применения темной темы: \(error)")
                    } else {
                        print("✅ DEBUG: Theme Темная тема применена")
                    }
                }
            } else {
                // Отключаем темную тему
                let lightThemeScript = """
                    (function() {
                        document.querySelectorAll('*').forEach(el => {
                            el.style.removeProperty('background-color');
                            el.style.removeProperty('color');
                            el.style.removeProperty('border-color');
                        });
                        if (document.body) {
                            document.body.style.removeProperty('background-color');
                            document.body.style.removeProperty('color');
                        }
                        if (document.documentElement) {
                            document.documentElement.style.removeProperty('background-color');
                            document.documentElement.style.removeProperty('color');
                        }
                    })();
                """
                webView.evaluateJavaScript(lightThemeScript) { result, error in
                    if let error = error {
                        print("❌ DEBUG: Theme Ошибка отключения темной темы: \(error)")
                    } else {
                        print("✅ DEBUG: Theme Темная тема отключена")
                    }
                }
            }
        }
        
        // MARK: - WKNavigationDelegate
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            print("DEBUG: Начало загрузки страницы")
            
            // Применяем тему как можно раньше
            let isDarkMode = parent?.interactor.appInteractor.appSettings.enableBrowserDarkMode ?? false
            if isDarkMode {
                DispatchQueue.main.async {
                    webView.evaluateJavaScript(self.parent?.interactor.darkThemeScript ?? "") { result, error in
                        if let error = error {
                            print("❌ Ошибка применения темы в didStartProvisionalNavigation: \(error)")
                        } else {
                            print("✅ Тема применена в didStartProvisionalNavigation")
                        }
                    }
                }
            }
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            // Обновляем состояние навигации при начале загрузки
            parent?.interactor.setCanGoBack(webView.canGoBack)
            parent?.interactor.setCanGoForward(webView.canGoForward)
            
            // Применяем тему при коммите навигации для предотвращения мигания
            let isDarkMode = parent?.interactor.appInteractor.appSettings.enableBrowserDarkMode ?? false
            if isDarkMode {
                DispatchQueue.main.async {
                    webView.evaluateJavaScript(self.parent?.interactor.darkThemeScript ?? "") { result, error in
                        if let error = error {
                            print("❌ Ошибка применения темы в didCommit: \(error)")
                        } else {
                            print("✅ Тема применена в didCommit")
                        }
                    }
                }
            }
            
            print("DEBUG: Загрузка страницы началась")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Обновляем состояние навигации при завершении загрузки
            parent?.interactor.setCanGoBack(webView.canGoBack)
            parent?.interactor.setCanGoForward(webView.canGoForward)
            
            // Обновляем URL в interactor (это автоматически сохранит его)
            if let currentURL = webView.url {
                parent?.interactor.updateAddress(currentURL)
            }
            
            // Принудительно применяем тему после загрузки страницы для исправления бага с первым запуском
            let isDarkMode = parent?.interactor.appInteractor.appSettings.enableBrowserDarkMode ?? false
            applyTheme(isDarkMode: isDarkMode)
            
            print("DEBUG: Загрузка страницы завершена")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            print("DEBUG: Ошибка загрузки страницы: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            // Разрешаем все навигационные действия для корректной работы ссылок
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                     for navigationAction: WKNavigationAction,
                     windowFeatures: WKWindowFeatures) -> WKWebView? {
            
            // Если запрос не из-за клика (например, form submit), разрешаем обычную навигацию
            guard navigationAction.targetFrame == nil || !(navigationAction.targetFrame?.isMainFrame ?? false) else {
                return nil
            }

            // Загружаем URL в том же WKWebView вместо создания нового
            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }
        
         
        // MARK: - KVO Observer
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard let webView = webView else { return }
            if keyPath == #keyPath(WKWebView.canGoBack) {
                parent?.interactor.setCanGoBack(webView.canGoBack)
            } else if keyPath == #keyPath(WKWebView.canGoForward) {
                parent?.interactor.setCanGoForward(webView.canGoForward)
            } else if keyPath == #keyPath(WKWebView.estimatedProgress) {
                parent?.interactor.updateLoadingProgress(webView.estimatedProgress)
            } else if  keyPath == #keyPath(WKWebView.url) {
                parent?.interactor.updateAddress(webView.url)
//                parent?.interactor.goToUrl(string: webView.url!.absoluteString) //TODO: MAKE UPDATING ADDRESS BAR
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
            addedContentRules()
        }
        
        func loadURL(_ url: URL) {
            webView?.load(URLRequest(url: url))
        }
        
        // MARK: - Resource Monitoring
        
        public func setupResourceMonitoring() {
            guard let webView = webView,
                  let resourceMonitor = parent?.interactor.getResourceMonitor() else { return }
            
            // Добавляем обработчики сообщений
            webView.configuration.userContentController.add(resourceMonitor, name: "resourceAnalysis")
            
            // Внедряем JavaScript для анализа ресурсов
            let analysisScript = WKUserScript(
                source: ResourceMonitor.buildResourceInfoJavascript(),
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
            webView.configuration.userContentController.addUserScript(analysisScript)
        }
        
        /// Added content Blocked Rules
        func addedContentRules() {
            let contentRuleListStore = WKContentRuleListStore.default()
            let rules = parent?.interactor.loadAdBlockRules()
            let identifier = "AdBlockRules"
            
            contentRuleListStore!.compileContentRuleList(forIdentifier: identifier, encodedContentRuleList: rules) { ruleList, error in
                if let ruleList = ruleList {
                    self.webView?.configuration.userContentController.add(ruleList)
                } else if let error = error {
                }
            }
        }
    }
}


