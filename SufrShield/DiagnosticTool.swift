import Foundation
import SafariServices

/// Инструмент для диагностики работы блокировщика рекламы
class DiagnosticTool {
    
    /// Запускает полную диагностику блокировщика
    static func runFullDiagnostic() -> String {
        var result = "🔍 ПОЛНАЯ ДИАГНОСТИКА БЛОКИРОВЩИКА РЕКЛАМЫ\n"
        result += "=" * 50 + "\n\n"
        
        // 1. Проверяем App Group
        result += checkAppGroupStatus()
        result += "\n"
        
        // 2. Проверяем файлы правил
        result += checkRulesFiles()
        result += "\n"
        
        // 3. Проверяем статус расширений
        result += checkExtensionsStatus()
        result += "\n"
        
        // 4. Проверяем содержимое правил
        result += analyzeRulesContent()
        result += "\n"
        
        // 5. Рекомендации
        result += getRecommendations()
        
        return result
    }
    
    /// Проверяет статус App Group
    static func checkAppGroupStatus() -> String {
        var result = "📁 СТАТУС APP GROUP:\n"
        
        let fileManager = FileManager.default
        let groupID = Constants.adblockGroupId
        
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            result += "❌ App Group недоступен: \(groupID)\n"
            result += "⚠️  Проверьте настройки проекта и entitlements\n"
            return result
        }
        
        result += "✅ App Group доступен: \(groupID)\n"
        result += "📂 Путь: \(groupURL.path)\n"
        
        return result
    }
    
    /// Проверяет файлы правил для всех расширений
    static func checkRulesFiles() -> String {
        var result = "📄 ФАЙЛЫ ПРАВИЛ:\n"
        
        for ruleType in RulesType.allCases {
            result += checkSingleRuleFile(ruleType)
        }
        
        return result
    }
    
    /// Проверяет один файл правил
    static func checkSingleRuleFile(_ ruleType: RulesType) -> String {
        var result = "• \(ruleType.rawValue).json: "
        
        guard let fileURL = ruleType.filePath else {
            result += "❌ Не удалось получить путь к файлу\n"
            return result
        }
        
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: fileURL.path) else {
            result += "❌ Файл не существует\n"
            return result
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let fileSize = data.count
            
            // Проверяем, что это валидный JSON
            let rules = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            let rulesCount = rules?.count ?? 0
            
            result += "✅ Размер: \(formatFileSize(fileSize)), Правил: \(rulesCount)\n"
            
            // Проверяем структуру первого правила
            if let firstRule = rules?.first {
                if firstRule["trigger"] != nil && firstRule["action"] != nil {
                    result += "  ✅ Структура правил корректна\n"
                } else {
                    result += "  ❌ Некорректная структура правил\n"
                }
            }
            
        } catch {
            result += "❌ Ошибка чтения: \(error.localizedDescription)\n"
        }
        
        return result
    }
    
    /// Анализирует содержимое правил
    static func analyzeRulesContent() -> String {
        var result = "🔍 АНАЛИЗ СОДЕРЖИМОГО ПРАВИЛ:\n"
        
        guard let adBlockURL = RulesType.adBlock.filePath,
              FileManager.default.fileExists(atPath: adBlockURL.path) else {
            result += "❌ Файл правил adBlock недоступен\n"
            return result
        }
        
        do {
            let data = try Data(contentsOf: adBlockURL)
            let rules = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            
            guard let rules = rules else {
                result += "❌ Не удалось парсить правила\n"
                return result
            }
            
            result += "📊 Всего правил: \(rules.count)\n"
            
            // Анализируем типы правил
            var blockRules = 0
            var urlFilters: Set<String> = []
            var resourceTypes: Set<String> = []
            
            for rule in rules {
                if let action = rule["action"] as? [String: Any],
                   action["type"] as? String == "block" {
                    blockRules += 1
                }
                
                if let trigger = rule["trigger"] as? [String: Any] {
                    if let urlFilter = trigger["url-filter"] as? String {
                        urlFilters.insert(urlFilter)
                    }
                    
                    if let resources = trigger["resource-type"] as? [String] {
                        resourceTypes.formUnion(resources)
                    }
                }
            }
            
            result += "🚫 Правил блокировки: \(blockRules)\n"
            result += "🎯 Уникальных URL-фильтров: \(urlFilters.count)\n"
            result += "📋 Типы ресурсов: \(resourceTypes.joined(separator: ", "))\n"
            
            // Показываем примеры правил
            result += "\n📝 ПРИМЕРЫ ПРАВИЛ:\n"
            for (index, rule) in rules.prefix(3).enumerated() {
                if let trigger = rule["trigger"] as? [String: Any],
                   let urlFilter = trigger["url-filter"] as? String {
                    result += "  \(index + 1). \(urlFilter)\n"
                }
            }
            
        } catch {
            result += "❌ Ошибка анализа: \(error.localizedDescription)\n"
        }
        
        return result
    }
    
    /// Проверяет статус всех расширений
    static func checkExtensionsStatus() -> String {
        var result = "📱 СТАТУС РАСШИРЕНИЙ:\n"
        
        let extensions = ["adblocker", "sequrity", "privacy"]
        
        for extensionName in extensions {
            if let status = getExtensionStatus(extensionName) {
                result += "• \(extensionName): \(status)\n"
            } else {
                result += "• \(extensionName): ❌ Статус недоступен\n"
            }
        }
        
        return result
    }
    
    /// Получает рекомендации по улучшению
    static func getRecommendations() -> String {
        var result = "💡 РЕКОМЕНДАЦИИ:\n"
        
        // Проверяем количество правил
        if let adBlockURL = RulesType.adBlock.filePath,
           FileManager.default.fileExists(atPath: adBlockURL.path),
           let data = try? Data(contentsOf: adBlockURL),
           let rules = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            
            if rules.count < 100 {
                result += "⚠️  Мало правил блокировки (\(rules.count)). Рекомендуется добавить больше доменов\n"
            } else if rules.count > 50000 {
                result += "⚠️  Очень много правил (\(rules.count)). Это может замедлить Safari\n"
            } else {
                result += "✅ Количество правил оптимально (\(rules.count))\n"
            }
        }
        
        result += "\n🧪 ТЕСТОВЫЕ САЙТЫ ДЛЯ ПРОВЕРКИ:\n"
        result += "• https://ads-blocker.com/testing/\n"
        result += "• https://www.cnn.com\n"
        result += "• https://www.forbes.com\n"
        result += "• https://www.dailymail.co.uk\n"
        
        result += "\n⚙️  НАСТРОЙКИ SAFARI:\n"
        result += "1. Откройте Настройки → Safari → Расширения\n"
        result += "2. Найдите SufrShield и включите все расширения\n"
        result += "3. Перезапустите Safari\n"
        
        return result
    }
    
    /// Получает статус конкретного расширения
    static func getExtensionStatus(_ extensionName: String) -> String? {
        let fileManager = FileManager.default
        let groupID = Constants.adblockGroupId
        
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            return nil
        }
        
        let statusFileURL = groupURL.appendingPathComponent("extension_status.json")
        
        guard fileManager.fileExists(atPath: statusFileURL.path) else {
            return "📄 Файл статуса не найден"
        }
        
        do {
            let data = try Data(contentsOf: statusFileURL)
            let status = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            
            guard let status = status else { return "❌ Ошибка парсинга статуса" }
            
            let success = status["success"] as? Bool ?? false
            let timestamp = status["timestamp"] as? TimeInterval ?? 0
            let error = status["error"] as? String
            
            if success {
                let date = Date(timeIntervalSince1970: timestamp)
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                
                return "✅ Правила загружены (\(formatter.string(from: date)))"
            } else {
                return "❌ Ошибка: \(error ?? "Неизвестная ошибка")"
            }
            
        } catch {
            return "❌ Ошибка чтения: \(error.localizedDescription)"
        }
    }
    
    /// Форматирует размер файла
    static func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - App Group Access Testing
extension DiagnosticTool {
    
    /// Тестирует доступ к App Group и запись/чтение файлов
    static func testAppGroupAccess() {
        let fileManager = FileManager.default
        let groupID = Constants.adblockGroupId
        
        print("🔍 Тестирование App Group: \(groupID)")
        
        // 1. Проверяем доступ к App Group
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            print("❌ Не удалось получить доступ к App Group: \(groupID)")
            return
        }
        
        print("✅ App Group доступен: \(groupURL.path)")
        
        // 2. Создаем тестовый файл
        let testFileURL = groupURL.appendingPathComponent("test_rules.json")
        let testRules = [
            [
                "trigger": [
                    "url-filter": ".*test.*",
                    "resource-type": ["script", "image"]
                ],
                "action": ["type": "block"]
            ]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: testRules, options: .prettyPrinted)
            try jsonData.write(to: testFileURL)
            print("✅ Тестовый файл создан: \(testFileURL.path)")
        } catch {
            print("❌ Ошибка создания тестового файла: \(error)")
            return
        }
        
        // 3. Проверяем, что файл существует
        guard fileManager.fileExists(atPath: testFileURL.path) else {
            print("❌ Тестовый файл не найден после создания")
            return
        }
        
        // 4. Читаем файл обратно
        do {
            let readData = try Data(contentsOf: testFileURL)
            let readRules = try JSONSerialization.jsonObject(with: readData) as? [[String: Any]]
            print("✅ Файл прочитан успешно, правил: \(readRules?.count ?? 0)")
        } catch {
            print("❌ Ошибка чтения тестового файла: \(error)")
        }
        
        // 5. Очищаем тестовый файл
        try? fileManager.removeItem(at: testFileURL)
        print("🧹 Тестовый файл удален")
    }
}

extension String {
    static func *(lhs: String, rhs: Int) -> String {
        return String(repeating: lhs, count: rhs)
    }
}
