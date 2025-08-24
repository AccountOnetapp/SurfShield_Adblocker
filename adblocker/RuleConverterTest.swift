import Foundation

class RuleConverterTest {
    
    /// Демонстрирует работу конвертера правил
    static func testConversion() {
        print("=== Тестирование конвертера правил блокировки ===\n")
        
        // Загружаем правила из файла
        guard let rulesPath = Bundle.main.path(forResource: "adblock_rules", ofType: "txt"),
              let rulesContent = try? String(contentsOfFile: rulesPath, encoding: .utf8) else {
            print("❌ Не удалось загрузить файл с правилами")
            return
        }
        
        let rules = rulesContent.components(separatedBy: .newlines)
        print("📋 Загружено правил: \(rules.count)")
        
        // Конвертируем в JSON
        let startTime = Date()
        let jsonString = RuleConverter.convertRulesToJSON(rules)
        let conversionTime = Date().timeIntervalSince(startTime)
        
        print("⚡ Время конвертации: \(String(format: "%.3f", conversionTime)) секунд")
        print("📊 Размер JSON: \(jsonString.count) символов")
        
        // Сохраняем в память устройства
        let saved = RuleConverter.saveRulesToDevice(jsonString, filename: "converted_blockerList")
        if saved {
            print("✅ Правила успешно сохранены в память устройства")
        } else {
            print("❌ Ошибка при сохранении правил")
        }
        
        // Показываем первые несколько правил
        print("\n🔍 Примеры сконвертированных правил:")
        if let jsonData = jsonString.data(using: .utf8),
           let jsonArray = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] {
            
            let sampleCount = min(5, jsonArray.count)
            for i in 0..<sampleCount {
                let rule = jsonArray[i]
                print("Правило \(i + 1): \(rule)")
            }
            
            if jsonArray.count > sampleCount {
                print("... и еще \(jsonArray.count - sampleCount) правил")
            }
        }
        
        print("\n=== Тестирование завершено ===")
    }
    
    /// Сравнивает размеры исходного и сконвертированного файлов
    static func compareFileSizes() {
        print("\n=== Сравнение размеров файлов ===")
        
        // Размер исходного файла
        if let rulesPath = Bundle.main.path(forResource: "adblock_rules", ofType: "txt"),
           let rulesContent = try? String(contentsOfFile: rulesPath, encoding: .utf8) {
            let originalSize = rulesContent.count
            print("📄 Исходный файл: \(originalSize) символов")
            
            // Размер сконвертированного JSON
            let rules = rulesContent.components(separatedBy: .newlines)
            let jsonString = RuleConverter.convertRulesToJSON(rules)
            let jsonSize = jsonString.count
            
            print("📊 JSON файл: \(jsonSize) символов")
            print("📈 Коэффициент сжатия: \(String(format: "%.2f", Double(jsonSize) / Double(originalSize)))")
        }
    }
}
