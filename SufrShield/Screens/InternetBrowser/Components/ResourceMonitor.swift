//
//  ResourceMonitor.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import Foundation
import WebKit

// MARK: - Resource Analysis Data
struct ResourceAnalysisData {
    let pageResources: [String]
    let loadedResources: [String]
    let blockedCount: Int
    let totalPageResources: Int
    let totalLoadedResources: Int
    let timestamp: Date
    
    var blockedPercentage: Double {
        guard totalPageResources > 0 else { return 0.0 }
        return Double(blockedCount) / Double(totalPageResources) * 100.0
    }
}

// MARK: - Resource Monitor Protocol
protocol ResourceMonitorDelegate: AnyObject {
    func resourceAnalysisCompleted(_ data: ResourceAnalysisData)
}

// MARK: - Resource Monitor
class ResourceMonitor: NSObject, WKScriptMessageHandler {
    
    // MARK: - Properties
    weak var delegate: ResourceMonitorDelegate?
    
    // MARK: - Initialization
    override init() {
        super.init()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body =   message.body as? [String: Any] else { return }
        
        switch message.name {
        case "resourceAnalysis":
            handleResourceAnalysis(body)
            break
        default:
            break
        }
    }
    
    private func handleResourceAnalysis(_ data: [String: Any]) {
        guard let pageResources = data["pageResources"] as? [String],
              let loadedResources = data["loadedResources"] as? [String],
              let blockedCount = data["blockedCount"] as? Int,
              let totalPageResources = data["totalPageResources"] as? Int,
              let totalLoadedResources = data["totalLoadedResources"] as? Int else { return }
        
        let analysisData = ResourceAnalysisData(
            pageResources: pageResources,
            loadedResources: loadedResources,
            blockedCount: blockedCount,
            totalPageResources: totalPageResources,
            totalLoadedResources: totalLoadedResources,
            timestamp: Date()
        )
        
        DispatchQueue.main.async {
            self.delegate?.resourceAnalysisCompleted(analysisData)
        }
        
        print("📊 ResourceMonitor: Анализ ресурсов завершен")
        print("   - Всего ресурсов на странице: \(totalPageResources)")
        print("   - Загружено ресурсов: \(totalLoadedResources)")
        print("   - Заблокировано ресурсов: \(blockedCount)")
        print("   - Процент блокировки: \(String(format: "%.1f", analysisData.blockedPercentage))%")
    }
    
    static func buildResourceInfoJavascript() -> String {
        let script = """
        function extractUrls(fromCss) {
            let matches = fromCss.match(/url\\(.+?\\)/g);
            if (!matches) {
                return [];
            }
            let urls = matches.map(url => url.replace(/url\\(['\\"]?(.+?)['\\"]?\\)/g, "$1"));
            return urls;
        }
        
        function getPageResources() {
            let pageResources = [...document.images].map(x => x.src);
            pageResources = [...pageResources, ...[...document.scripts].map(x => x.src)];
            pageResources = [...pageResources, ...[...document.getElementsByTagName("link")].map(x => x.href)];
        
            [...document.styleSheets].forEach(sheet => {
                // Игнорируем кросс-доменные стили
                if (sheet.href && !sheet.href.startsWith(window.location.origin)) {
                    return;
                }
                try {
                    if (!sheet.cssRules) {
                        return;
                    }
                    [...sheet.cssRules].forEach(rule => {
                        pageResources = [...pageResources, ...extractUrls(rule.cssText)];
                    });
                } catch(e) {
                    // Нет доступа к cssRules, пропускаем
                    return;
                }
            });
        
            let inlineStyles = document.querySelectorAll('*[style]');
            [...inlineStyles].forEach(x => {
                pageResources = [...pageResources, ...extractUrls(x.getAttributeNode("style").value)];
            });
        
            let backgrounds = document.querySelectorAll('td[background], tr[background], table[background]');
            [...backgrounds].forEach(x => {
                pageResources.push(x.getAttributeNode("background").value);
            });
        
            return pageResources.filter(x => (x != null && x != ''));
        }
        
        function analyzeResources() {
            let pageResources = getPageResources();
            let loadedResources = window.performance.getEntriesByType('resource').map(x => x.name);
            
            // Фильтруем пустые, null, undefined ресурсы
            let cleanPageResources = pageResources.filter(x => x && x !== '' && x !== 'null' && x !== 'undefined');
            let cleanLoadedResources = loadedResources.filter(x => x && x !== '' && x !== 'null' && x !== 'undefined');
            
            // Убираем дубликаты
            let uniquePageResources = [...new Set(cleanPageResources)];
            let uniqueLoadedResources = [...new Set(cleanLoadedResources)];
        
            let resourceInfo = {
                'pageResources': uniquePageResources,
                'loadedResources': uniqueLoadedResources,
                'blockedCount': uniquePageResources.length - uniqueLoadedResources.length,
                'totalPageResources': uniquePageResources.length,
                'totalLoadedResources': uniqueLoadedResources.length
            };
        
            // Отправляем данные в нативное приложение
            if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers.resourceAnalysis) {
                window.webkit.messageHandlers.resourceAnalysis.postMessage(resourceInfo);
            }
        
            console.log('📊 ResourceMonitor: Анализ ресурсов завершен');
            console.log('   - Всего ресурсов на странице:', resourceInfo.totalPageResources);
            console.log('   - Загружено ресурсов:', resourceInfo.totalLoadedResources);
            console.log('   - Заблокировано ресурсов:', resourceInfo.blockedCount);
            console.log('   - Процент блокировки:', (resourceInfo.blockedCount / resourceInfo.totalPageResources * 100).toFixed(1) + '%');
            
            // Примеры для отладки
            console.log('📋 Примеры ресурсов на странице:', uniquePageResources.slice(0, 5));
            console.log('📋 Примеры загруженных ресурсов:', uniqueLoadedResources.slice(0, 5));
            return JSON.stringify(resourceInfo);
        }
        
        // Запускаем анализ сразу
        analyzeResources();
        """
        
        return script
    }

}
