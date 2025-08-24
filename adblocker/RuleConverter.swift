import Foundation

class RuleConverter {
    
    /// Конвертирует правила блокировки в формат JSON для Content Blocker Extension
    /// - Parameter rules: Массив строк с правилами блокировки
    /// - Returns: JSON строка в формате Content Blocker Extension
    static func convertRulesToJSON(_ rules: [String]) -> String {
        var jsonRules: [[String: Any]] = []
        
        for rule in rules {
            guard !rule.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            
            let jsonRule = convertSingleRule(rule)
            if let validRule = jsonRule {
                jsonRules.append(validRule)
            }
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonRules, options: [.prettyPrinted])
            return String(data: jsonData, encoding: .utf8) ?? "[]"
        } catch {
            print("Ошибка при создании JSON: \(error)")
            return "[]"
        }
    }
    
    /// Конвертирует одно правило в формат JSON
    /// - Parameter rule: Строка с правилом блокировки
    /// - Returns: Словарь с правилом в формате JSON или nil если правило невалидно
    private static func convertSingleRule(_ rule: String) -> [String: Any]? {
        let trimmedRule = rule.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Пропускаем комментарии и пустые строки
        if trimmedRule.hasPrefix("//") || trimmedRule.hasPrefix("#") || trimmedRule.isEmpty {
            return nil
        }
        
        var trigger: [String: Any] = [:]
        var action: [String: Any] = ["type": "block"]
        
        // Обработка различных типов правил
        if trimmedRule.contains("$") {
            // Правило с модификаторами
            let components = trimmedRule.components(separatedBy: "$")
            let urlFilter = components[0]
            let modifiers = components[1]
            
            trigger["url-filter"] = urlFilter.isEmpty ? ".*" : urlFilter
            
            // Парсинг модификаторов
            let modifierArray = modifiers.components(separatedBy: ",")
            for modifier in modifierArray {
                let trimmedModifier = modifier.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if trimmedModifier.hasPrefix("~") {
                    // Исключение домена
                    let domain = String(trimmedModifier.dropFirst())
                    if trigger["if-domain"] == nil {
                        trigger["if-domain"] = []
                    }
                    if var ifDomain = trigger["if-domain"] as? [String] {
                        ifDomain.append(domain)
                        trigger["if-domain"] = ifDomain
                    } else {
                        trigger["if-domain"] = [domain]
                    }
                } else if trimmedModifier.hasPrefix("domain=") {
                    // Специфичные домены
                    let domainPart = String(trimmedModifier.dropFirst(7))
                    let domains = domainPart.components(separatedBy: "|")
                    var finalDomains: [String] = []
                    
                    for domain in domains {
                        let trimmedDomain = domain.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmedDomain.hasPrefix("~") {
                            finalDomains.append(String(trimmedDomain.dropFirst()))
                        } else {
                            finalDomains.append(trimmedDomain)
                        }
                    }
                    
                    if !finalDomains.isEmpty {
                        trigger["if-domain"] = finalDomains
                    }
                } else if trimmedModifier == "script" {
                    trigger["resource-type"] = ["script"]
                } else if trimmedModifier == "image" {
                    trigger["resource-type"] = ["image"]
                } else if trimmedModifier == "stylesheet" {
                    trigger["resource-type"] = ["style-sheet"]
                } else if trimmedModifier == "xmlhttprequest" {
                    trigger["resource-type"] = ["raw"]
                } else if trimmedModifier == "third-party" {
                    trigger["load-type"] = ["third-party"]
                } else if trimmedModifier == "object" {
                    trigger["resource-type"] = ["object"]
                }
            }
        } else {
            // Простое правило без модификаторов
            trigger["url-filter"] = trimmedRule.isEmpty ? ".*" : trimmedRule
        }
        
        // Если url-filter пустой, используем .*
        if let urlFilter = trigger["url-filter"] as? String, urlFilter.isEmpty {
            trigger["url-filter"] = ".*"
        }
        
        return [
            "trigger": trigger,
            "action": action
        ]
    }
    
    /// Сохраняет JSON правила в память устройства
    /// - Parameters:
    ///   - jsonString: JSON строка для сохранения
    ///   - filename: Имя файла для сохранения
    /// - Returns: true если сохранение прошло успешно, false в противном случае
    static func saveRulesToDevice(_ jsonString: String, filename: String = "blockerList") -> Bool {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Не удалось получить путь к документам")
            return false
        }
        
        let fileURL = documentsPath.appendingPathComponent("\(filename).json")
        
        do {
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Правила успешно сохранены в: \(fileURL.path)")
            return true
        } catch {
            print("Ошибка при сохранении правил: \(error)")
            return false
        }
    }
    
    /// Загружает правила из памяти устройства
    /// - Parameter filename: Имя файла для загрузки
    /// - Returns: JSON строка или nil если загрузка не удалась
    static func loadRulesFromDevice(filename: String = "blockerList") -> String? {
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Не удалось получить путь к документам")
            return nil
        }
        
        let fileURL = documentsPath.appendingPathComponent("\(filename).json")
        
        do {
            let jsonString = try String(contentsOf: fileURL, encoding: .utf8)
            return jsonString
        } catch {
            print("Ошибка при загрузке правил: \(error)")
            return nil
        }
    }
}
