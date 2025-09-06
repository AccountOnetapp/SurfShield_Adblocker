//
//  ResourceMonitor.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import Foundation
import WebKit

// MARK: - Resource Monitor Protocol
protocol ResourceMonitorDelegate: AnyObject {
    func resourceWasBlocked(_ resource: BlockedResource)
    func resourceWasLoaded(_ url: String, size: Int64)
}

// MARK: - Resource Monitor
class ResourceMonitor: NSObject, WKScriptMessageHandler {
    
    // MARK: - Properties
    weak var delegate: ResourceMonitorDelegate?
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else { return }
        
        switch message.name {
        case "resourceBlocked":
            handleResourceBlocked(body)
        case "resourceLoaded":
            handleResourceLoaded(body)
        default:
            break
        }
    }
    
    // MARK: - Private Methods
    
    private func handleResourceBlocked(_ data: [String: Any]) {
        guard let url = data["url"] as? String,
              let size = data["size"] as? Int64 else { return }
        
        let resource = BlockedResource(
            url: url,
            size: size,
            type: .init(from: url),
            timestamp: Date(),
            reason: .adDomain
        )
        
        DispatchQueue.main.async {
            self.delegate?.resourceWasBlocked(resource)
        }
    }
    
    private func handleResourceLoaded(_ data: [String: Any]) {
        guard let url = data["url"] as? String,
              let size = data["size"] as? Int64 else { return }
        
        DispatchQueue.main.async {
            self.delegate?.resourceWasLoaded(url, size: size)
        }
    }
    
    // MARK: - JavaScript Injection
    
    /// Генерирует JavaScript код с правилами блокировки
    static func getMonitoringScript(with rules: RulesParser.ParsedRules) -> String {
        return RulesParser.generateJavaScript(with: rules)
    }
    
    /// Генерирует JavaScript код с fallback правилами
    static func getFallbackMonitoringScript() -> String {
        
        let fallbackRules = RulesParser.ParsedRules(
            domains: loadDomainsFromFile(),
            patterns: [
                "/ads/", "/advertisement/", "/banner/", "/popup/", "/tracking/",
                "googleads", "doubleclick", "googlesyndication", "analytics", "adservice",
                "adtracker", "adnetwork", "affiliate", "sponsor", "clicks", "conversion",
                "impression", "trackingpixel", "leadbolt", "popunder", "interstitial",
                "videoad", "ad_placement", "adsystem", "adserver", "adclick",
                "advertising", "adtech", "adexchange", "admob", "adsafe", "adskeeper",
                "adpush", "adroll", "taboola", "outbrain"
            ],
            urlFilters: []
        )
        
        return RulesParser.generateJavaScript(with: fallbackRules)
    }
    
    /// Загружает домены из файла domains.txt
    private static func loadDomainsFromFile() -> [String] {
        // Загружаем из файла в проекте
        do {
            let rulesPath = Bundle.main.path(forResource: "domains", ofType: "txt")!
            let rulesString = try String(contentsOfFile: rulesPath, encoding: .utf8)
            let lines = rulesString.components(separatedBy: .newlines)
            return lines
        } catch {
            print("⚠️ Не удалось загрузить domains.txt, используем базовые домены")
            return [
//                "googleadservices.com", "googlesyndication.com", "doubleclick.net",
//                "facebook.com/tr", "analytics.google.com", "googletagmanager.com",
//                "google-analytics.com", "amazon-adsystem.com", "adsystem.amazon.com"
            ]
        }
    }
    
   
}
