//
//  RulesParser.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import Foundation

// MARK: - Rules Parser
class RulesParser {
    
    // MARK: - Parsed Rules Structure
    struct ParsedRules {
        let domains: [String]
        let patterns: [String]
        let urlFilters: [String]
        
        var isEmpty: Bool {
            return domains.isEmpty && patterns.isEmpty && urlFilters.isEmpty
        }
    }
    
    // MARK: - Public Methods
    
    /// Парсит JSON правила и возвращает структурированные данные
    static func parseRules(from jsonString: String) -> ParsedRules {
        var domains: Set<String> = []
        var patterns: Set<String> = []
        var urlFilters: [String] = []
        
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let rules = json["rules"] as? [[String: Any]] else {
            print("❌ Ошибка парсинга JSON правил")
            return ParsedRules(domains: [], patterns: [], urlFilters: [])
        }
        
        for rule in rules {
            guard let action = rule["action"] as? [String: Any],
                  let type = action["type"] as? String,
                  type == "block" else {
                continue
            }
            
            guard let trigger = rule["trigger"] as? [String: Any] else {
                continue
            }
            
            // Обрабатываем url-filter
            if let urlFilter = trigger["url-filter"] as? String {
                urlFilters.append(urlFilter)
                
                // Извлекаем домен из URL фильтра
                if let domain = extractDomain(from: urlFilter) {
                    domains.insert(domain)
                }
                
                // Извлекаем паттерн
                if let pattern = extractPattern(from: urlFilter) {
                    patterns.insert(pattern)
                }
            }
            
            // Обрабатываем url-filter-is-case-sensitive
            if let caseSensitive = trigger["url-filter-is-case-sensitive"] as? Bool, caseSensitive {
                // Для case-sensitive правил добавляем как есть
                if let urlFilter = trigger["url-filter"] as? String {
                    patterns.insert(urlFilter)
                }
            }
            
            // Обрабатываем if-domain
            if let ifDomains = trigger["if-domain"] as? [String] {
                for domain in ifDomains {
                    let cleanDomain = domain.replacingOccurrences(of: "*", with: "")
                    if !cleanDomain.isEmpty {
                        domains.insert(cleanDomain)
                    }
                }
            }
            
            // Обрабатываем unless-domain
            if let unlessDomains = trigger["unless-domain"] as? [String] {
                for domain in unlessDomains {
                    let cleanDomain = domain.replacingOccurrences(of: "*", with: "")
                    if !cleanDomain.isEmpty {
                        domains.insert(cleanDomain)
                    }
                }
            }
        }
        
        print("✅ Парсинг правил завершен:")
        print("   - Доменов: \(domains.count)")
        print("   - Паттернов: \(patterns.count)")
        print("   - URL фильтров: \(urlFilters.count)")
        
        return ParsedRules(
            domains: Array(domains),
            patterns: Array(patterns),
            urlFilters: urlFilters
        )
    }
    
    // MARK: - Private Methods
    
    private static func extractDomain(from urlFilter: String) -> String? {
        // Улучшенное извлечение домена из URL фильтра
        let cleanFilter = urlFilter.replacingOccurrences(of: "\\", with: "")
        
        if cleanFilter.contains("://") {
            let components = cleanFilter.components(separatedBy: "://")
            if components.count > 1 {
                let domainPart = components[1].components(separatedBy: "/")[0]
                let cleanDomain = domainPart
                    .replacingOccurrences(of: "*", with: "")
                    .replacingOccurrences(of: "^", with: "")
                    .replacingOccurrences(of: "$", with: "")
                
                if !cleanDomain.isEmpty && cleanDomain != "." {
                    return cleanDomain
                }
            }
        } else if cleanFilter.hasPrefix("||") {
            // Обрабатываем паттерны типа ||example.com
            let domain = String(cleanFilter.dropFirst(2))
            let cleanDomain = domain
                .components(separatedBy: "/")[0]
                .replacingOccurrences(of: "*", with: "")
                .replacingOccurrences(of: "^", with: "")
                .replacingOccurrences(of: "$", with: "")
            
            if !cleanDomain.isEmpty && cleanDomain != "." {
                return cleanDomain
            }
        } else if !cleanFilter.contains("/") && !cleanFilter.contains("*") {
            // Простой домен без протокола
            let cleanDomain = cleanFilter
                .replacingOccurrences(of: "^", with: "")
                .replacingOccurrences(of: "$", with: "")
            
            if !cleanDomain.isEmpty && cleanDomain != "." {
                return cleanDomain
            }
        }
        
        return nil
    }
    
    private static func extractPattern(from urlFilter: String) -> String? {
        // Извлекаем паттерны для поиска в URL
        let cleanFilter = urlFilter.replacingOccurrences(of: "\\", with: "")
        
        // Убираем специальные символы регулярных выражений для простого поиска
        let pattern = cleanFilter
            .replacingOccurrences(of: "^", with: "")
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: "||", with: "")
            .replacingOccurrences(of: "|", with: "")
        
        if pattern.count > 2 && !pattern.contains("://") {
            return pattern
        }
        
        return nil
    }
    
    // MARK: - JavaScript Generation
    static func domainsToJSArrayString(_ domains: [String]) -> String {
        let trimmedDomains = domains.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                                    .filter { !$0.isEmpty } // Убираем пустые строки
        let quotedDomains = trimmedDomains.map { "\"\($0)\"" }
        return quotedDomains.joined(separator: ",")
    }
    /// Генерирует JavaScript код с правилами блокировки
    static func generateJavaScript(with rules: ParsedRules) -> String {
//        let domainsJS = rules.domains.map { "'\($0)'" }.joined(separator: ", ")
        let domainsJS = RulesParser.domainsToJSArrayString(rules.domains)
        let patternsJS = RulesParser.domainsToJSArrayString(rules.patterns)
        
        return """
        (function() {
            // Загруженные правила блокировки
            const blockedDomains = [\(domainsJS)];
            const blockedPatterns = [\(patternsJS)];
            
            console.log('📋 Загружено правил: \(rules.domains.count) доменов, \(rules.patterns.count) паттернов');
            
            // Функция для проверки, должен ли ресурс быть заблокирован
            function shouldBlockResource(url) {
                try {
                    const host = new URL(url).hostname.toLowerCase();
                    const urlLower = url.toLowerCase();
                    
                    // Проверяем домены
                    for (const domain of blockedDomains) {
                        if (host.includes(domain.toLowerCase())) {
                            return true;
                        }
                    }
                    
                    // Проверяем паттерны
                    for (const pattern of blockedPatterns) {
                        if (urlLower.includes(pattern.toLowerCase())) {
                            return true;
                        }
                    }
                    
                    return false;
                } catch (e) {
                    return false;
                }
            }
            
            // Перехватываем fetch запросы
            const originalFetch = window.fetch;
            window.fetch = function(...args) {
                const url = args[0];
                if (typeof url === 'string' && shouldBlockResource(url)) {
                    console.log('🚫 Заблокирован fetch:', url);
                    window.webkit.messageHandlers.resourceBlocked.postMessage({
                        url: url,
                        size: 0
                    });
                    return Promise.reject(new Error('Blocked'));
                }
                
                return originalFetch.apply(this, args).then(response => {
                    if (response.ok) {
                        const size = parseInt(response.headers.get('content-length') || '0');
                        window.webkit.messageHandlers.resourceLoaded.postMessage({
                            url: url,
                            size: size
                        });
                    }
                    return response;
                });
            };
            
            // Перехватываем XMLHttpRequest
            const originalXHROpen = XMLHttpRequest.prototype.open;
            XMLHttpRequest.prototype.open = function(method, url, ...args) {
                this._url = url;
                return originalXHROpen.apply(this, [method, url, ...args]);
            };
            
            const originalXHRSend = XMLHttpRequest.prototype.send;
            XMLHttpRequest.prototype.send = function(...args) {
                if (this._url && shouldBlockResource(this._url)) {
                    console.log('🚫 Заблокирован XHR:', this._url);
                    window.webkit.messageHandlers.resourceBlocked.postMessage({
                        url: this._url,
                        size: 0
                    });
                    return;
                }
                
                this.addEventListener('load', function() {
                    if (this.status === 200) {
                        const size = parseInt(this.getResponseHeader('content-length') || '0');
                        window.webkit.messageHandlers.resourceLoaded.postMessage({
                            url: this._url,
                            size: size
                        });
                    }
                });
                
                return originalXHRSend.apply(this, args);
            };
            
            // Перехватываем создание изображений
            const originalImage = window.Image;
            window.Image = function() {
                const img = new originalImage();
                const originalSrc = Object.getOwnPropertyDescriptor(HTMLImageElement.prototype, 'src');
                
                Object.defineProperty(img, 'src', {
                    get: originalSrc.get,
                    set: function(value) {
                        if (shouldBlockResource(value)) {
                            console.log('🚫 Заблокировано изображение:', value);
                            window.webkit.messageHandlers.resourceBlocked.postMessage({
                                url: value,
                                size: 0
                            });
                            return;
                        }
                        originalSrc.set.call(this, value);
                    }
                });
                
                return img;
            };
            
            console.log('✅ ResourceMonitor с правилами активен');
        })();
        """
    }
}
