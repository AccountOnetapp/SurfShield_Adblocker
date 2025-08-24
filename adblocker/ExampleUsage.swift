import Foundation

/// Примеры использования конвертера правил блокировки рекламы
class ExampleUsage {
    
    /// Пример 1: Базовая конвертация правил
    static func basicConversionExample() {
        print("=== Пример 1: Базовая конвертация ===")
        
        let simpleRules = [
            ".ads.$script",
            ".banner.$image",
            ".popup.$popup"
        ]
        
        let jsonString = RuleConverter.convertRulesToJSON(simpleRules)
        print("Сконвертированные правила:")
        print(jsonString)
        print()
    }
    
    /// Пример 2: Правила с доменами
    static func domainRulesExample() {
        print("=== Пример 2: Правила с доменами ===")
        
        let domainRules = [
            ".advert.$domain=~advert.ae|~advert.ge",
            ".tracker.$script,third-party,domain=~trusted.com",
            ".ads.$~image,domain=~ads.example.com"
        ]
        
        let jsonString = RuleConverter.convertRulesToJSON(domainRules)
        print("Правила с доменами:")
        print(jsonString)
        print()
    }
    
    /// Пример 3: Сохранение и загрузка правил
    static func saveLoadExample() {
        print("=== Пример 3: Сохранение и загрузка ===")
        
        let rules = [
            ".ads.$script",
            ".banner.$image",
            ".popup.$popup"
        ]
        
        // Конвертируем и сохраняем
        let jsonString = RuleConverter.convertRulesToJSON(rules)
        let saved = RuleConverter.saveRulesToDevice(jsonString, filename: "example_rules")
        
        if saved {
            print("✅ Правила сохранены")
            
            // Загружаем обратно
            if let loadedRules = RuleConverter.loadRulesFromDevice(filename: "example_rules") {
                print("✅ Правила загружены:")
                print(loadedRules)
            } else {
                print("❌ Ошибка загрузки правил")
            }
        } else {
            print("❌ Ошибка сохранения правил")
        }
        print()
    }
    
    /// Пример 4: Обработка сложных правил
    static func complexRulesExample() {
        print("=== Пример 4: Сложные правила ===")
        
        let complexRules = [
            ".adriver.$~object,domain=~adriver.co",
            ".ads.controller.js$script",
            ".advert.$domain=~advert.ae|~advert.ge|~advert.io",
            ".ar/ads/$~xmlhttprequest",
            ".biz/?ce=$third-party"
        ]
        
        let jsonString = RuleConverter.convertRulesToJSON(complexRules)
        print("Сложные правила:")
        print(jsonString)
        print()
    }
    
    /// Пример 5: Валидация правил
    static func validationExample() {
        print("=== Пример 5: Валидация правил ===")
        
        let mixedRules = [
            ".ads.$script",           // Валидное правило
            "",                       // Пустая строка (будет пропущена)
            "// Комментарий",         // Комментарий (будет пропущен)
            "# Другой комментарий",   // Комментарий (будет пропущен)
            ".banner.$image",         // Валидное правило
            "   ",                    // Только пробелы (будет пропущена)
            ".popup.$popup"           // Валидное правило
        ]
        
        let jsonString = RuleConverter.convertRulesToJSON(mixedRules)
        print("Правила после валидации:")
        print(jsonString)
        print()
    }
    
    /// Пример 6: Производительность
    static func performanceExample() {
        print("=== Пример 6: Тест производительности ===")
        
        // Создаем большое количество правил
        var largeRules: [String] = []
        for i in 1...1000 {
            largeRules.append(".ad\(i).$script")
        }
        
        let startTime = Date()
        let jsonString = RuleConverter.convertRulesToJSON(largeRules)
        let conversionTime = Date().timeIntervalSince(startTime)
        
        print("📊 Правил: \(largeRules.count)")
        print("⚡ Время конвертации: \(String(format: "%.3f", conversionTime)) секунд")
        print("📈 Размер JSON: \(jsonString.count) символов")
        print("🚀 Скорость: \(String(format: "%.0f", Double(largeRules.count) / conversionTime)) правил/сек")
        print()
    }
    
    /// Запуск всех примеров
    static func runAllExamples() {
        print("🚀 Запуск примеров использования конвертера правил")
        print("=" * 50)
        print()
        
        basicConversionExample()
        domainRulesExample()
        saveLoadExample()
        complexRulesExample()
        validationExample()
        performanceExample()
        
        print("✅ Все примеры выполнены!")
    }
}

// Расширение для повторения строки
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}
