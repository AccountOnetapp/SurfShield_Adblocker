//import Foundation
//
//// Мост для использования RuleConverter из основного приложения
//// Этот файл позволяет основному приложению использовать функциональность конвертера
//
//
///*
//## Как использовать конвертацию EasyList
//
//Теперь у вас есть несколько способов конвертации:
//
//### 1. **Базовая конвертация EasyList**
//```swift
//// В вашем коде
//let success = RuleConverterBridge.convertEasyListRules()
//if success {
//    print("✅ Правила EasyList успешно сконвертированы!")
//}
//```
//
//### 2. **Чанковая конвертация для больших файлов**
//```swift
//// Разбивает на файлы по 40000 правил
//let success = RuleConverterBridge.convertEasyListRulesChunked(maxRulesPerChunk: 40000)
//```
//
//### 3. **Получение статистики**
//```swift
//let stats = RuleConverterBridge.getEasyListStatistics()
//print("📊 Всего правил: \(stats["validRules"] ?? 0)")
//print(" Скрипты: \(stats["scriptRules"] ?? 0)")
//print("🖼️ Изображения: \(stats["imageRules"] ?? 0)")
//```
//
//### 4. **Проверка совместимости**
//```swift
//let compatibility = RuleConverterBridge.checkEasyListCompatibility()
//print("🔍 Совместимость: \(compatibility["compatibilityPercentage"] ?? "0%")")
//```
//
//## Основные преимущества
//
//✅ **Оптимизированная обработка EasyList** - специальные методы для работы с форматом
//✅ **Чанковая обработка** - разбивает большие файлы на управляемые части
//✅ **Извлечение доменов** - автоматически создает оптимизированные правила
//✅ **Белый список** - корректно обрабатывает исключения
//✅ **Статистика** - подробная информация о правилах
//✅ **Проверка совместимости** - выявляет неподдерживаемые паттерны
//
//Теперь ваш `RuleConverterBridge` полностью готов к работе с правилами EasyList!
//
// */
// 
//class RuleConverterBridge {
//    
//    /// Конвертирует правила блокировки в JSON формат
//    /// - Parameter rules: Массив строк с правилами
//    /// - Returns: JSON строка
//    static func convertRules(_ rules: [String]) -> String {
////        print("🔄 RuleConverterBridge: Начинаю конвертацию \(rules.count) правил...")
//        
//        // Загружаем правила из файла adblock_rules.txt
//        guard let rulesPath = Bundle.main.path(forResource: "adblock_rules", ofType: "txt") else {
//            print("❌ RuleConverterBridge: Файл adblock_rules.txt не найден")
//            return "[]"
//        }
//        
//        do {
//            let rulesContent = try String(contentsOfFile: rulesPath, encoding: .utf8)
//            let rulesArray = rulesContent.components(separatedBy: .newlines)
//            
//            print("📋 RuleConverterBridge: Загружено \(rulesArray.count) правил из adblock_rules.txt")
//            
//            // Фильтруем только валидные правила
//            let validRules = rulesArray.filter { rule in
//                let trimmed = rule.trimmingCharacters(in: .whitespacesAndNewlines)
//                return !trimmed.isEmpty && !trimmed.hasPrefix("//") && !trimmed.hasPrefix("#")
//            }
//            
//            print("✅ RuleConverterBridge: Найдено \(validRules.count) валидных правил")
//            
//            // Используем RuleConverter для конвертации
////            let result = RuleConverter.convertRulesToJSON(validRules)
//            print("✅ RuleConverterBridge: Конвертация завершена")
//            return "Временно ничего"
////            return result
//        } catch {
//            print("❌ RuleConverterBridge: Ошибка при загрузке правил: \(error)")
//            return "[]"
//        }
//    }
//    
//    /// Загружает правила блокировки из файла
//    /// - Returns: Массив строк с правилами
//    static func loadAdblockRules() -> [String] {
//        guard let rulesPath = Bundle.main.path(forResource: "adblock_rules", ofType: "txt") else {
//            print("❌ RuleConverterBridge: Файл adblock_rules.txt не найден")
//            return []
//        }
//        
//        do {
//            let rulesContent = try String(contentsOfFile: rulesPath, encoding: .utf8)
//            let rulesArray = rulesContent.components(separatedBy: .newlines)
//            
//            // Фильтруем только валидные правила
//            let validRules = rulesArray.filter { rule in
//                let trimmed = rule.trimmingCharacters(in: .whitespacesAndNewlines)
//                return !trimmed.isEmpty && !trimmed.hasPrefix("//") && !trimmed.hasPrefix("#")
//            }
//            
//            print("📋 RuleConverterBridge: Загружено \(validRules.count) валидных правил из \(rulesArray.count) строк")
//            return validRules
//        } catch {
//            print("❌ RuleConverterBridge: Ошибка при загрузке правил: \(error)")
//            return []
//        }
//    }
//    
//    /// Получает количество активных правил блокировки
//    /// - Returns: Количество правил
//    static func getRulesCount() -> Int {
//        let rules = loadAdblockRules()
//        return rules.count
//    }
//    
//    /// Проверяет статус блокировки рекламы
//    /// - Returns: true если блокировка активна
//    static func isAdBlockingEnabled() -> Bool {
//        // Здесь можно добавить проверку статуса Content Blocker Extension
//        // Пока возвращаем заглушку
//        return UserDefaults.standard.bool(forKey: "adBlockingEnabled")
//    }
//    
//    /// Включает/выключает блокировку рекламы
//    /// - Parameter enabled: true для включения, false для выключения
//    static func setAdBlockingEnabled(_ enabled: Bool) {
//        print("🔄 RuleConverterBridge: Установка статуса блокировки: \(enabled)")
//        
//        UserDefaults.standard.set(enabled, forKey: "adBlockingEnabled")
//        
//        if enabled {
//            // Конвертируем и сохраняем правила
//            let rules = loadAdblockRules()
//            print("📋 RuleConverterBridge: Найдено \(rules.count) правил для конвертации")
//            
////            let jsonRules = RuleConverter.convertRulesToJSON(rules)
////            let saved = saveRules(jsonRules)
//            
////            if saved {
////                print("✅ RuleConverterBridge: Правила блокировки успешно конвертированы и сохранены")
////                print("📊 Размер JSON: \(jsonRules.count) символов")
////                
////                // Сохраняем время обновления
////                UserDefaults.standard.set(Date(), forKey: "lastRulesUpdate")
////                
////                // Уведомляем расширение Safari о новых правилах
////                notifySafariExtension()
////            } else {
////                print("❌ RuleConverterBridge: Ошибка при сохранении правил блокировки")
////            }
////        } else {
////            print("🔄 RuleConverterBridge: Блокировка рекламы отключена")
////        }
////    }
//    
//    /// Уведомляет расширение Safari о новых правилах
//    private static func notifySafariExtension() {
//        // Отправляем уведомление для обновления правил в расширении
//        NotificationCenter.default.post(
//            name: NSNotification.Name("AdblockerRulesUpdated"),
//            object: nil,
//            userInfo: ["rulesCount": getRulesCount()]
//        )
//        
//        print("📢 RuleConverterBridge: Уведомление отправлено расширению Safari")
//    }
//    
//    /// Предварительно конвертирует все правила для быстрой загрузки
//    /// - Returns: true если конвертация прошла успешно
//    static func preconvertAllRules() -> Bool {
//        print("🔄 RuleConverterBridge: Начинаю предварительную конвертацию всех правил...")
//        
//        let rules = loadAdblockRules()
//        let validRulesCount = rules.count
//        
//        print("📋 RuleConverterBridge: Найдено \(validRulesCount) валидных правил")
//        
//        if validRulesCount == 0 {
//            print("⚠️ RuleConverterBridge: Нет правил для конвертации")
//            return false
//        }
//        
//        let startTime = Date()
////        let jsonRules = RuleConverter.convertRulesToJSON(rules)
//        let conversionTime = Date().timeIntervalSince(startTime)
//        
//        print("⚡ RuleConverterBridge: Конвертация завершена за \(String(format: "%.2f", conversionTime)) секунд")
//        print("📊 Размер JSON: \(jsonRules.count) символов")
//        
//        // Сохраняем конвертированные правила
//        let saved = saveRules(jsonRules)
//        
//        if saved {
//            print("✅ RuleConverterBridge: Правила успешно сохранены для использования в расширении Safari")
//            UserDefaults.standard.set(Date(), forKey: "lastRulesUpdate")
//            return true
//        } else {
//            print("❌ RuleConverterBridge: Ошибка при сохранении конвертированных правил")
//            return false
//        }
//    }
//    
//    /// Получает статистику по правилам
//    /// - Returns: Словарь со статистикой
//    static func getRulesStatistics() -> [String: Any] {
//        let rules = loadAdblockRules()
//        let totalLines = rules.count
//        let validCount = rules.count
//        
//        // Анализируем типы правил
//        var scriptRules = 0
//        var imageRules = 0
//        var stylesheetRules = 0
//        var domainRules = 0
//        
//        for rule in rules {
//            if rule.contains("$script") { scriptRules += 1 }
//            if rule.contains("$image") { imageRules += 1 }
//            if rule.contains("$stylesheet") { stylesheetRules += 1 }
//            if rule.contains("domain=") { domainRules += 1 }
//        }
//        
//        return [
//            "totalLines": totalLines,
//            "validRules": validCount,
//            "scriptRules": scriptRules,
//            "imageRules": imageRules,
//            "stylesheetRules": stylesheetRules,
//            "domainRules": domainRules,
//            "lastUpdate": UserDefaults.standard.object(forKey: "lastRulesUpdate") as? Date ?? Date()
//        ]
//    }
//    
//    /// Обновляет правила блокировки
//    /// - Returns: true если обновление прошло успешно
//    static func refreshRules() -> Bool {
//        print("🔄 RuleConverterBridge: Обновление правил блокировки...")
//        return preconvertAllRules()
//    }
//    
//    /// Сохраняет правила в память устройства
//    /// - Parameters:
//    ///   - jsonString: JSON строка для сохранения
//    ///   - filename: Имя файла
//    /// - Returns: true если сохранение прошло успешно
//    static func saveRules(_ jsonString: String, filename: String = "converted_blockerList") -> Bool {
//        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            print("❌ RuleConverterBridge: Не удалось получить путь к документам")
//            return false
//        }
//        
//        let fileURL = documentsPath.appendingPathComponent("\(filename).json")
//        
//        do {
//            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
//            print("✅ RuleConverterBridge: Правила блокировки сохранены в: \(fileURL.path)")
//            print("📊 Размер файла: \(jsonString.count) символов")
//            return true
//        } catch {
//            print("❌ RuleConverterBridge: Ошибка при сохранении правил: \(error)")
//            return false
//        }
//    }
//    
//    /// Загружает правила из памяти устройства
//    /// - Parameter filename: Имя файла для загрузки
//    /// - Returns: JSON строка или nil
//    static func loadRules(filename: String = "converted_blockerList") -> String? {
//        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            print("❌ RuleConverterBridge: Не удалось получить путь к документам")
//            return nil
//        }
//        
//        let fileURL = documentsPath.appendingPathComponent("\(filename).json")
//        
//        do {
//            let jsonString = try String(contentsOf: fileURL, encoding: .utf8)
//            print("✅ RuleConverterBridge: Правила загружены из: \(fileURL.path)")
//            return jsonString
//        } catch {
//            print("❌ RuleConverterBridge: Ошибка при загрузке правил: \(error)")
//            return nil
//        }
//    }
//    
//    /// Проверяет, есть ли конвертированные правила
//    /// - Returns: true если правила существуют
//    static func hasConvertedRules() -> Bool {
//        return loadRules() != nil
//    }
//    
//    /// Получает размер конвертированных правил
//    /// - Returns: Размер в байтах или 0
//    static func getConvertedRulesSize() -> Int {
//        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
//            return 0
//        }
//        
//        let fileURL = documentsPath.appendingPathComponent("converted_blockerList.json")
//        
//        do {
//            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
//            return attributes[.size] as? Int ?? 0
//        } catch {
//            return 0
//        }
//    }
//
//    /// Специальная конвертация правил EasyList с оптимизацией
//    /// - Returns: true если конвертация прошла успешно
//    static func convertEasyListRules() -> Bool {
//        print("🔄 RuleConverterBridge: Начинаю конвертацию правил EasyList...")
//        
//        let rules = loadAdblockRules()
//        let validRulesCount = rules.count
//        
//        print("📋 RuleConverterBridge: Найдено \(validRulesCount) правил EasyList")
//        
//        if validRulesCount == 0 {
//            print("⚠️ RuleConverterBridge: Нет правил EasyList для конвертации")
//            return false
//        }
//        
//        let startTime = Date()
//        
//        // Используем специальный метод для EasyList
////        let jsonRules = RuleConverter.convertEasyListRules(rules)
//        let conversionTime = Date().timeIntervalSince(startTime)
//        
//        print("⚡ RuleConverterBridge: Конвертация EasyList завершена за \(String(format: "%.2f", conversionTime)) секунд")
//        print("📊 Размер JSON: \(jsonRules.count) символов")
//        
//        // Сохраняем конвертированные правила
//        let saved = saveRules(jsonRules, filename: "easyList_blockerList")
//        
//        if saved {
//            print("✅ RuleConverterBridge: Правила EasyList успешно сохранены")
//            UserDefaults.standard.set(Date(), forKey: "lastEasyListUpdate")
//            return true
//        } else {
//            print("❌ RuleConverterBridge: Ошибка при сохранении правил EasyList")
//            return false
//        }
//    }
//    
//    /// Конвертирует правила EasyList с разбивкой на чанки для больших файлов
//    /// - Parameter maxRulesPerChunk: Максимальное количество правил в чанке
//    /// - Returns: true если конвертация прошла успешно
//    static func convertEasyListRulesChunked(maxRulesPerChunk: Int = 40000) -> Bool {
//        print("🔄 RuleConverterBridge: Начинаю чанковую конвертацию EasyList...")
//        
//        let rules = loadAdblockRules()
//        let validRulesCount = rules.count
//        
//        print("📋 RuleConverterBridge: Найдено \(validRulesCount) правил EasyList")
//        
//        if validRulesCount == 0 {
//            print("⚠️ RuleConverterBridge: Нет правил EasyList для конвертации")
//            return false
//        }
//        
//        let startTime = Date()
//        
//        // Используем чанковую генерацию
////        RuleConverter.generateBlockingFiles(
////            domains: extractDomainsFromRules(rules),
////            whitelist: extractWhitelistDomains(rules),
////            maxRulesPerFile: maxRulesPerChunk
////        ) {
////            let totalTime = Date().timeIntervalSince(startTime)
////            print("✅ RuleConverterBridge: Чанковая конвертация EasyList завершена за \(String(format: "%.2f", totalTime)) секунд")
////            
////            // Сохраняем время обновления
////            UserDefaults.standard.set(Date(), forKey: "lastEasyListChunkedUpdate")
////        }
////        
//        return true
//    }
//    
//    /// Извлекает домены из правил EasyList для оптимизации
//    /// - Parameter rules: Массив правил EasyList
//    /// - Returns: Массив доменов для блокировки
//    private static func extractDomainsFromRules(_ rules: [String]) -> [String] {
//        var domains: Set<String> = []
//        
//        for rule in rules {
//            let trimmedRule = rule.trimmingCharacters(in: .whitespacesAndNewlines)
//            
//            // Пропускаем комментарии и мета-правила
//            if trimmedRule.hasPrefix("!") || trimmedRule.hasPrefix("[") || trimmedRule.isEmpty {
//                continue
//            }
//            
//            // Извлекаем домены из правил типа ||domain.com
//            if trimmedRule.hasPrefix("||") {
//                let domain = String(trimmedRule.dropFirst(2))
//                if let dotIndex = domain.firstIndex(of: ".") {
//                    let cleanDomain = String(domain[..<dotIndex])
//                    if cleanDomain.count > 1 {
//                        domains.insert(cleanDomain)
//                    }
//                }
//            }
//            
//            // Извлекаем домены из правил с domain= модификатором
//            if trimmedRule.contains("domain=") {
//                let components = trimmedRule.components(separatedBy: "$")
//                if components.count > 1 {
//                    let modifiers = components[1]
//                    let domainMatches = modifiers.components(separatedBy: ",")
//                    
//                    for match in domainMatches {
//                        if match.hasPrefix("domain=") {
//                            let domainPart = String(match.dropFirst(7))
//                            let domainList = domainPart.components(separatedBy: "|")
//                            
//                            for domain in domainList {
//                                let cleanDomain = domain.replacingOccurrences(of: "~", with: "")
//                                if cleanDomain.count > 1 && !cleanDomain.contains("~") {
//                                    domains.insert(cleanDomain)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        
//        print("🌐 RuleConverterBridge: Извлечено \(domains.count) уникальных доменов")
//        return Array(domains)
//    }
//    
//    /// Извлекает домены белого списка из правил EasyList
//    /// - Parameter rules: Массив правил EasyList
//    /// - Returns: Массив доменов для исключения
//    private static func extractWhitelistDomains(_ rules: [String]) -> [String] {
//        var whitelistDomains: Set<String> = []
//        
//        for rule in rules {
//            let trimmedRule = rule.trimmingCharacters(in: .whitespacesAndNewlines)
//            
//            // Ищем правила с исключениями доменов
//            if trimmedRule.contains("domain=") {
//                let components = trimmedRule.components(separatedBy: "$")
//                if components.count > 1 {
//                    let modifiers = components[1]
//                    let domainMatches = modifiers.components(separatedBy: ",")
//                    
//                    for match in domainMatches {
//                        if match.hasPrefix("domain=") {
//                            let domainPart = String(match.dropFirst(7))
//                            let domainList = domainPart.components(separatedBy: "|")
//                            
//                            for domain in domainList {
//                                if domain.hasPrefix("~") {
//                                    let cleanDomain = String(domain.dropFirst())
//                                    if cleanDomain.count > 1 {
//                                        whitelistDomains.insert(cleanDomain)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        
//        print("🔒 RuleConverterBridge: Найдено \(whitelistDomains.count) доменов в белом списке")
//        return Array(whitelistDomains)
//    }
//    
//    /// Получает расширенную статистику по правилам EasyList
//    /// - Returns: Словарь со статистикой
//    static func getEasyListStatistics() -> [String: Any] {
//        let rules = loadAdblockRules()
//        let totalLines = rules.count
//        
//        // Анализируем типы правил EasyList
//        var scriptRules = 0
//        var imageRules = 0
//        var stylesheetRules = 0
//        var domainRules = 0
//        var thirdPartyRules = 0
//        var commentLines = 0
//        var metaLines = 0
//        
//        for rule in rules {
//            let trimmedRule = rule.trimmingCharacters(in: .whitespacesAndNewlines)
//            
//            if trimmedRule.hasPrefix("!") {
//                commentLines += 1
//            } else if trimmedRule.hasPrefix("[") || trimmedRule.hasPrefix("]") {
//                metaLines += 1
//            } else if trimmedRule.contains("$script") {
//                scriptRules += 1
//            } else if trimmedRule.contains("$image") {
//                imageRules += 1
//            } else if trimmedRule.contains("$stylesheet") {
//                stylesheetRules += 1
//            } else if trimmedRule.contains("domain=") {
//                domainRules += 1
//            } else if trimmedRule.contains("$third-party") {
//                thirdPartyRules += 1
//            }
//        }
//        
//        let validRules = totalLines - commentLines - metaLines
//        
//        return [
//            "totalLines": totalLines,
//            "validRules": validRules,
//            "commentLines": commentLines,
//            "metaLines": metaLines,
//            "scriptRules": scriptRules,
//            "imageRules": imageRules,
//            "stylesheetRules": stylesheetRules,
//            "domainRules": domainRules,
//            "thirdPartyRules": thirdPartyRules,
//            "lastUpdate": UserDefaults.standard.object(forKey: "lastEasyListUpdate") as? Date ?? Date(),
//            "lastChunkedUpdate": UserDefaults.standard.object(forKey: "lastEasyListChunkedUpdate") as? Date
//        ]
//    }
//    
//    /// Проверяет совместимость правил EasyList с Content Blocker Extension
//    /// - Returns: Словарь с результатами проверки
//    static func checkEasyListCompatibility() -> [String: Any] {
//        let rules = loadAdblockRules()
//        var compatibleRules = 0
//        var incompatibleRules = 0
//        var unsupportedPatterns: [String] = []
//        
//        for rule in rules {
//            if RuleConverter.isRuleSupported(rule) {
//                compatibleRules += 1
//            } else {
//                incompatibleRules += 1
//                let trimmedRule = rule.trimmingCharacters(in: .whitespacesAndNewlines)
//                if !trimmedRule.isEmpty {
//                    unsupportedPatterns.append(trimmedRule)
//                }
//            }
//        }
//        
//        let compatibilityPercentage = rules.count > 0 ? Double(compatibleRules) / Double(rules.count) * 100 : 0
//        
//        return [
//            "totalRules": rules.count,
//            "compatibleRules": compatibleRules,
//            "incompatibleRules": incompatibleRules,
//            "compatibilityPercentage": String(format: "%.1f", compatibilityPercentage),
//            "unsupportedPatterns": Array(unsupportedPatterns.prefix(10)) // Показываем первые 10
//        ]
//    }
//}
