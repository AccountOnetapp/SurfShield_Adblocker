//import Foundation
//
///// Инструмент для диагностики работы блокировщика рекламы
//class DiagnosticTool {
//    
//    /// Запускает полную диагностику блокировщика
//    static func runFullDiagnostic() -> String {
//        var report = "🔍 ДИАГНОСТИКА БЛОКИРОВЩИКА РЕКЛАМЫ\n"
//        report += "=====================================\n\n"
//        
//        // 1. Проверка файлов
//        report += "📁 ПРОВЕРКА ФАЙЛОВ:\n"
//        report += checkFiles()
//        report += "\n"
//        
//        // 2. Проверка правил
//        report += "📋 ПРОВЕРКА ПРАВИЛ:\n"
//        report += checkRules()
//        report += "\n"
//        
//        // 3. Проверка конвертации
//        report += "🔄 ПРОВЕРКА КОНВЕРТАЦИИ:\n"
//        report += checkConversion()
//        report += "\n"
//        
//        // 4. Рекомендации
//        report += "💡 РЕКОМЕНДАЦИИ:\n"
//        report += generateRecommendations()
//        
//        return report
//    }
//    
//    /// Проверяет наличие необходимых файлов
//    private static func checkFiles() -> String {
//        var result = ""
//        
//        // Проверяем adblock_rules.txt
//        if let rulesPath = Bundle.main.path(forResource: "adblock_rules", ofType: "txt") {
//            let fileSize = (try? FileManager.default.attributesOfItem(atPath: rulesPath)[.size] as? Int) ?? 0
//            result += "✅ adblock_rules.txt найден (размер: \(fileSize) байт)\n"
//        } else {
//            result += "❌ adblock_rules.txt НЕ НАЙДЕН\n"
//        }
//        
//        // Проверяем blockerList.json
//        if let blockerPath = Bundle.main.path(forResource: "blockerList", ofType: "json") {
//            let fileSize = (try? FileManager.default.attributesOfItem(atPath: blockerPath)[.size] ?? 0) as? Int ?? 0
//            result += "✅ blockerList.json найден (размер: \(fileSize) байт)\n"
//        } else {
//            result += "❌ blockerList.json НЕ НАЙДЕН\n"
//        }
//        
//        return result
//    }
//    
//    /// Проверяет правила блокировки
//    private static func checkRules() -> String {
//        var result = ""
//        
//        // Загружаем правила из adblock_rules.txt
//        if let rulesPath = Bundle.main.path(forResource: "adblock_rules", ofType: "txt"),
//           let content = try? String(contentsOfFile: rulesPath, encoding: .utf8) {
//            let lines = content.components(separatedBy: .newlines)
//            let nonEmptyLines = lines.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
//            let commentLines = lines.filter { $0.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("//") || $0.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("#") }
//            
//            result += "📊 adblock_rules.txt:\n"
//            result += "   • Всего строк: \(lines.count)\n"
//            result += "   • Непустых строк: \(nonEmptyLines.count)\n"
//            result += "   • Комментариев: \(commentLines.count)\n"
//            result += "   • Правил: \(nonEmptyLines.count - commentLines.count)\n"
//            
//            // Показываем первые несколько правил
//            let actualRules = nonEmptyLines.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("//") && !$0.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("#") }
//            if !actualRules.isEmpty {
//                result += "   • Примеры правил:\n"
//                for (index, rule) in actualRules.prefix(3).enumerated() {
//                    result += "     \(index + 1). \(rule)\n"
//                }
//            }
//        } else {
//            result += "❌ Не удалось загрузить adblock_rules.txt\n"
//        }
//        
//        return result
//    }
//    
//    /// Проверяет конвертацию правил
//    private static func checkConversion() -> String {
//        var result = ""
//        
//        // Проверяем конвертацию через RuleConverterBridge
////        let rulesCount = RuleConverterBridge.getRulesCount()
////        let stats = RuleConverterBridge.getRulesStatistics()
//        
//        result += "🔄 Статистика конвертации:\n"
//        result += "   • Всего правил: \(rulesCount)\n"
//        
//        if let totalLines = stats["totalLines"] as? Int {
//            result += "   • Всего строк: \(totalLines)\n"
//        }
//        
//        if let validRules = stats["validRules"] as? Int {
//            result += "   • Валидных правил: \(validRules)\n"
//        }
//        
//        if let scriptRules = stats["scriptRules"] as? Int {
//            result += "   • Правил для скриптов: \(scriptRules)\n"
//        }
//        
//        if let imageRules = stats["imageRules"] as? Int {
//            result += "   • Правил для изображений: \(imageRules)\n"
//        }
//        
//        return result
//    }
//    
//    /// Генерирует рекомендации по устранению проблем
//    private static func generateRecommendations() -> String {
//        var result = ""
//        
//        result += "🚨 ВОЗМОЖНЫЕ ПРОБЛЕМЫ И РЕШЕНИЯ:\n\n"
//        
//        result += "1. **Расширение не включено в Safari**\n"
//        result += "   Решение: Настройки → Safari → Расширения → Включить SufrShield\n\n"
//        
//        result += "2. **Правила не загружены**\n"
//        result += "   Решение: Нажать 'Обновить правила' в приложении\n\n"
//        
//        result += "3. **Неправильный формат правил**\n"
//        result += "   Решение: Проверить синтаксис в adblock_rules.txt\n\n"
//        
//        result += "4. **Кэш Safari**\n"
//        result += "   Решение: Перезапустить Safari или очистить кэш\n\n"
//        
//        result += "5. **Проблемы с подписью**\n"
//        result += "   Решение: Пересобрать проект в Xcode\n\n"
//        
//        return result
//    }
//}
