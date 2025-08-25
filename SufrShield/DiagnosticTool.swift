import Foundation

/// Инструмент для диагностики работы блокировщика рекламы
class DiagnosticTool {
    
    /// Запускает полную диагностику блокировщика
    static func runFullDiagnostic() -> String {
        var result = "🔍 Диагностика блокировщика рекламы\n\n"
        
        // Проверяем App Group
        testAppGroupAccess()
        
        // Проверяем статус расширений
        result += checkExtensionsStatus()
        
        return result
    }
    
    /// Проверяет статус всех расширений
    static func checkExtensionsStatus() -> String {
        var result = "📱 Статус расширений:\n"
        
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
