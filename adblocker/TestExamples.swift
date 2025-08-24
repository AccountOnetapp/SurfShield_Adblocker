import Foundation

/// Тестовые примеры для конвертера правил блокировки рекламы
class TestExamples {
    
    /// Запускает все тесты
    static func runAllTests() {
        print("🚀 Тестирование конвертера правил блокировки")
        print(String(repeating: "=", count: 50))
        print()
        
        testBasicRules()
        testDomainRules()
        testComplexRules()
        testValidation()
        testPerformance()
        
        print("✅ Все тесты выполнены!")
    }
    
    /// Тест 1: Базовые правила
    static func testBasicRules() {
        print("=== Тест 1: Базовые правила ===")
        
        let simpleRules = [
            ".ads.$script",
            ".banner.$image",
            ".popup.$popup"
        ]
        
        print("📋 Исходные правила:")
        for rule in simpleRules {
            print("  \(rule)")
        }
        
        // Показываем ожидаемую структуру JSON
        print("\n📊 Ожидаемая структура JSON:")
        print("""
[
  {
    "trigger": {
      "url-filter": ".ads.",
      "resource-type": ["script"]
    },
    "action": {
      "type": "block"
    }
  }
]
""")
        
        print("✅ Тест 1 завершен\n")
    }
    
    /// Тест 2: Правила с доменами
    static func testDomainRules() {
        print("=== Тест 2: Правила с доменами ===")
        
        let domainRules = [
            ".advert.$domain=~advert.ae|~advert.ge",
            ".tracker.$script,third-party"
        ]
        
        print("📋 Правила с доменами:")
        for rule in domainRules {
            print("  \(rule)")
        }
        
        print("\n📊 Ожидаемая структура JSON:")
        print("""
[
  {
    "trigger": {
      "url-filter": ".advert.",
      "if-domain": ["advert.ae", "advert.ge"]
    },
    "action": {
      "type": "block"
    }
  }
]
""")
        
        print("✅ Тест 2 завершен\n")
    }
    
    /// Тест 3: Сложные правила
    static func testComplexRules() {
        print("=== Тест 3: Сложные правила ===")
        
        let complexRules = [
            ".adriver.$~object,domain=~adriver.co",
            ".ads.controller.js$script",
            ".ar/ads/$~xmlhttprequest"
        ]
        
        print("📋 Сложные правила:")
        for rule in complexRules {
            print("  \(rule)")
        }
        
        print("\n📊 Ожидаемая структура JSON:")
        print("""
[
  {
    "trigger": {
      "url-filter": ".adriver.",
      "if-domain": ["object"],
      "if-domain": ["adriver.co"]
    },
    "action": {
      "type": "block"
    }
  }
]
""")
        
        print("✅ Тест 3 завершен\n")
    }
    
    /// Тест 4: Валидация правил
    static func testValidation() {
        print("=== Тест 4: Валидация правил ===")
        
        let mixedRules = [
            ".ads.$script",           // ✅ Валидное правило
            "",                       // ❌ Пустая строка
            "// Комментарий",         // ❌ Комментарий
            "# Другой комментарий",   // ❌ Комментарий
            ".banner.$image",         // ✅ Валидное правило
            "   ",                    // ❌ Только пробелы
            ".popup.$popup"           // ✅ Валидное правило
        ]
        
        print("📋 Смешанные правила:")
        for (_, rule) in mixedRules.enumerated() {
            let isValid = !rule.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && 
                         !rule.hasPrefix("//") && 
                         !rule.hasPrefix("#")
            let status = isValid ? "✅" : "❌"
            print("  \(status) \(rule)")
        }
        
        let validCount = mixedRules.filter { rule in
            let trimmed = rule.trimmingCharacters(in: .whitespacesAndNewlines)
            return !trimmed.isEmpty && !trimmed.hasPrefix("//") && !trimmed.hasPrefix("#")
        }.count
        
        print("\n📊 Статистика валидации:")
        print("  Всего правил: \(mixedRules.count)")
        print("  Валидных: \(validCount)")
        print("  Невалидных: \(mixedRules.count - validCount)")
        
        print("✅ Тест 4 завершен\n")
    }
    
    /// Тест 5: Производительность
    static func testPerformance() {
        print("=== Тест 5: Тест производительности ===")
        
        // Создаем большое количество правил
        var largeRules: [String] = []
        for i in 1...100 {
            largeRules.append(".ad\(i).$script")
        }
        
        print("📊 Создано правил: \(largeRules.count)")
        
        // Имитируем конвертацию
        let startTime = Date()
        var jsonRules: [[String: Any]] = []
        
        for rule in largeRules {
            let trigger: [String: Any] = [
                "url-filter": rule.replacingOccurrences(of: "$script", with: ""),
                "resource-type": ["script"]
            ]
            let action: [String: Any] = ["type": "block"]
            
            jsonRules.append([
                "trigger": trigger,
                "action": action
            ])
        }
        
        let conversionTime = Date().timeIntervalSince(startTime)
        
        print("⚡ Время конвертации: \(String(format: "%.3f", conversionTime)) секунд")
        print("📈 Размер JSON: ~\(jsonRules.count * 150) символов")
        print("🚀 Скорость: \(String(format: "%.0f", Double(largeRules.count) / conversionTime)) правил/сек")
        
        print("✅ Тест 5 завершен\n")
    }
    
    /// Тест 6: Сравнение размеров
    static func testSizeComparison() {
        print("=== Тест 6: Сравнение размеров ===")
        
        let sampleRules = [
            ".ads.$script",
            ".banner.$image",
            ".popup.$popup",
            ".tracker.$script,third-party",
            ".advert.$domain=~advert.ae|~advert.ge"
        ]
        
        let originalSize = sampleRules.joined(separator: "\n").count
        let estimatedJsonSize = sampleRules.count * 150 // Примерный размер JSON
        
        print("📊 Исходный размер: \(originalSize) символов")
        print("📈 Примерный JSON размер: \(estimatedJsonSize) символов")
        print("🚀 Коэффициент сжатия: \(String(format: "%.2f", Double(estimatedJsonSize) / Double(originalSize)))x")
        
        print("✅ Тест 6 завершен\n")
    }
}
