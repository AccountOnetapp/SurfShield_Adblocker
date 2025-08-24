import Foundation

/// Конвертер правил блокировки рекламы для использования в Xcode
class ConvertRules {
    
    /// Конвертирует правила из текстового файла в JSON
    /// - Parameters:
    ///   - inputFile: Путь к входному файлу
    ///   - outputFile: Путь к выходному файлу
    /// - Returns: true если конвертация прошла успешно
    static func convertFile(inputFile: String, outputFile: String) -> Bool {
        print("🔧 Конвертер правил блокировки рекламы")
        print("=====================================\n")
        
        print("📁 Входной файл: \(inputFile)")
        print("📁 Выходной файл: \(outputFile)\n")
        
        // Загружаем правила из файла
        guard let rulesContent = try? String(contentsOfFile: inputFile, encoding: .utf8) else {
            print("❌ Ошибка: Не удалось прочитать файл \(inputFile)")
            return false
        }
        
        let rules = rulesContent.components(separatedBy: .newlines)
        print("📋 Загружено правил: \(rules.count)")
        
        // Фильтруем пустые строки и комментарии
        let validRules = rules.filter { rule in
            let trimmed = rule.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty && !trimmed.hasPrefix("//") && !trimmed.hasPrefix("#")
        }
        
        print("✅ Валидных правил: \(validRules.count)\n")
        
        // Конвертируем в JSON
        print("⚡ Конвертация в JSON...")
        let startTime = Date()
        
        let jsonRules = convertRulesToJSON(validRules)
        let conversionTime = Date().timeIntervalSince(startTime)
        print("✅ Конвертация завершена за \(String(format: "%.3f", conversionTime)) секунд")
        
        // Создаем JSON
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: jsonRules, options: [.prettyPrinted])
            let jsonString = String(data: jsonData, encoding: .utf8) ?? "[]"
            
            // Сохраняем в файл
            try jsonString.write(toFile: outputFile, atomically: true, encoding: .utf8)
            
            print("💾 JSON сохранен в файл: \(outputFile)")
            print("📊 Размер JSON: \(jsonString.count) символов")
            print("📈 Коэффициент сжатия: \(String(format: "%.2f", Double(jsonString.count) / Double(rulesContent.count)))")
            
            // Показываем примеры
            print("\n🔍 Примеры сконвертированных правил:")
            let sampleCount = min(3, jsonRules.count)
            for i in 0..<sampleCount {
                let rule = jsonRules[i]
                print("Правило \(i + 1): \(rule)")
            }
            
            if jsonRules.count > sampleCount {
                print("... и еще \(jsonRules.count - sampleCount) правил")
            }
            
            print("\n🎉 Конвертация завершена успешно!")
            return true
            
        } catch {
            print("❌ Ошибка при создании JSON: \(error)")
            return false
        }
    }
    
    /// Конвертирует массив правил в JSON формат
    /// - Parameter rules: Массив строк с правилами
    /// - Returns: Массив словарей в формате JSON для Content Blocker Extension
    static func convertRulesToJSON(_ rules: [String]) -> [[String: Any]] {
        var jsonRules: [[String: Any]] = []
        
        for rule in rules {
            guard !rule.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            
            let jsonRule = convertSingleRule(rule)
            if let validRule = jsonRule {
                jsonRules.append(validRule)
            }
        }
        
        return jsonRules
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
        let action: [String: Any] = ["type": "block"]
        
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
    
    /// Тестирует конвертацию на примере
    static func testConversion() {
        print("🧪 Тестирование конвертера правил")
        print(String(repeating: "=", count: 40))
        
        let testRules = [
            ".ads.$script",
            ".banner.$image",
            ".popup.$popup",
            ".tracker.$script,third-party"
        ]
        
        let jsonRules = convertRulesToJSON(testRules)
        
        print("📋 Тестовые правила:")
        for rule in testRules {
            print("  \(rule)")
        }
        
        print("\n📊 Результат конвертации:")
        for (index, rule) in jsonRules.enumerated() {
            print("Правило \(index + 1): \(rule)")
        }
        
        print("\n✅ Тестирование завершено!")
    }
}
