//
//  RulesConverter.swift
//  SufrShield
//
//  Created by Артур Кулик on 25.08.2025.
//
import Foundation
import SafariServices
import SwiftyJSON

/// Модуль блокировщика рекламы
public enum RulesConverter {
    // MARK: Open Properties
    
    // MARK: Internal Properties
    internal static var groupID: String = Constants.adblockGroupId
    internal static var extensionsBundles: [String] = Constants.BlockExtenesionBundleIds.all
    
    /// Получить URL по каторому находится файл для определенного экстеншна
    /// - Parameters:
    ///   - type: тип екстеншена, для которго нужно получить URL
    /// - Returns: URL по каторому находится файл
    public static func getExtensionFileURL(forType type: RulesType) -> URL? {
        return type.filePath
    }
    
    /// Получить URL для Content Blocker Extension с fallback к bundle
    /// - Parameter type: тип расширения
    /// - Returns: URL файла правил или fallback к bundle
    public static func getExtensionFileURLWithFallback(forType type: RulesType) -> URL? {
        // Пытаемся получить файл из App Group
        if let appGroupURL = type.filePath,
           FileManager.default.fileExists(atPath: appGroupURL.path) {
            return appGroupURL
        }
        
        // Fallback к файлу из bundle
//        return Bundle.main.url(forResource: "blockerList", withExtension: "json")
        return nil
    }
}


/// Тип екстеншена блокировщика
public enum RulesType: String, Codable, CaseIterable {
    case adBlock
    case sequrity
    case privacy
    
    /// Получить URL по каторому находится файл для определенного экстеншна
    /// - Returns: URL по каторому находится файл
    internal var filePath: URL? {
        let fileManager = FileManager.default
        // Используй App Group вместо Documents
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RulesConverter.groupID) else {
            return nil
        }
        let fileURL = groupURL.appendingPathComponent("\(self.rawValue).json")
        return fileURL
    }
    
    private var fileName: String {
        return self.rawValue + ".json"
    }

    internal func writeRules(_ rules: String) {
        guard let filePath = filePath else { return }
        let fileManager = FileManager.default
        
        
        try? rules.write(to: filePath, atomically: true, encoding: .utf8)
        
        if fileManager.fileExists(atPath: filePath.path) {
            print("\(self.rawValue) successfully write to file", filePath.absoluteURL)
        } else {
            print("\(self.rawValue) cant write to file with path \(filePath.absoluteURL)")
        }
    }
}

extension RulesConverter {
    
    private static var workItem: DispatchWorkItem?
    
//    public static func start(groupID: String, extensionsBundles: [String]) {
    public static func start() {
        generateFiles()
    }
    
    /// Простой тестовый метод для загрузки готовых правил
    public static func loadTestRules() {
        print("🧪 Загружаем тестовые правила...")
        
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            print("❌ Не удалось получить доступ к App Group: \(groupID)")
            return
        }
        
        // Путь к тестовому файлу в bundle
        guard let testRulesPath = Bundle.main.path(forResource: "test_rules", ofType: "json") else {
            print("❌ Файл test_rules.json не найден в bundle")
            return
        }
        
        // Читаем содержимое тестового файла
        do {
            let testRulesData = try Data(contentsOf: URL(fileURLWithPath: testRulesPath))
            let testRulesString = String(data: testRulesData, encoding: .utf8) ?? ""
            
            print("✅ Тестовые правила прочитаны, размер: \(testRulesString.count) символов")
            
            // Сохраняем в App Group
            let targetFileURL = groupURL.appendingPathComponent("new_rules.json")
            try testRulesString.write(to: targetFileURL, atomically: true, encoding: .utf8)
            
            if fileManager.fileExists(atPath: targetFileURL.path) {
                print("✅ Тестовые правила сохранены в App Group: \(targetFileURL.path)")
                
                // Перезагружаем расширения
                DispatchQueue.main.async {
                    reloadExtensions(bundles: extensionsBundles, maxRetries: extensionsBundles.count) {
                        print("✅ Расширения перезагружены")
                    }
                }
            } else {
                print("❌ Не удалось сохранить тестовые правила")
            }
            
        } catch {
            print("❌ Ошибка при работе с тестовыми правилами: \(error)")
        }
    }
    
    private static func generateFiles(completion: @escaping (() -> Void) = {}) {
        workItem?.cancel()
        
        let currentWorkItem = DispatchWorkItem {
            do {
                let domains = try loadAndParseDomains()
                let preparedRules = convertDomainsToSafariRules(domains)
                saveRulesToFiles(preparedRules)
                
                DispatchQueue.main.async {
                    reloadExtensions(bundles: extensionsBundles, maxRetries: extensionsBundles.count, completion: completion)
                }
            } catch {
                print("❌ Ошибка генерации файлов: \(error)")
                DispatchQueue.main.async { completion() }
            }
        }
        
        workItem = currentWorkItem
        DispatchQueue.global(qos: .userInteractive).async(execute: currentWorkItem)
    }
    
    
    private static func reloadExtensions(bundles: [String], maxRetries: Int, completion: @escaping () -> Void) {
        guard !bundles.isEmpty else { 
            completion()
            return 
        }
        
        var reloadResults = [String: Bool]()
        
        for bundle in bundles {
            SFContentBlockerManager.reloadContentBlocker(withIdentifier: bundle) { error in
                reloadResults[bundle] = (error == nil)
                
                guard reloadResults.count == bundles.count else { return }
                
                handleReloadResults(reloadResults, maxRetries: maxRetries, completion: completion)
            }
        }
    }

    private static func handleReloadResults(_ results: [String: Bool], maxRetries: Int, completion: @escaping () -> Void) {
        let failedBundles = results.compactMap { key, success in key }
        
        if failedBundles.isEmpty || maxRetries <= 0 {
            DispatchQueue.main.async { completion() }
            return
        }
        
        reloadExtensions(bundles: failedBundles, maxRetries: maxRetries - 1, completion: completion)
    }
}

// MARK: - Private Helper Methods
extension RulesConverter {
    private static func loadAndParseDomains() throws -> [String] {
        print("🔄 Начинаем загрузку и парсинг доменов...")
        
        guard let rulesPath = Bundle.main.path(forResource: "adblock_rules", ofType: "txt") else {
            print("❌ Файл adblock_rules.txt не найден")
            throw RulesConverterError.fileNotFound
        }
        
        print("✅ Файл найден: \(rulesPath)")
        
        let rulesString = try String(contentsOfFile: rulesPath, encoding: .utf8)
        print("📄 Файл прочитан, размер: \(rulesString.count) символов")
        
        let lines = rulesString.components(separatedBy: .newlines)
        print("📝 Разделено на строки: \(lines.count)")
        
        let domains = lines.compactMap(parseDomainFromLine)
        print("🌐 Извлечено доменов: \(domains.count)")
        
        return domains
    }
    
    private static func parseDomainFromLine(_ line: String) -> String? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty, !trimmed.hasPrefix("!"), !trimmed.hasPrefix("[") else { return nil }
        
        // Парсинг правил формата ||domain^
        if trimmed.hasPrefix("||"), let domainEnd = trimmed.firstIndex(of: "^") {
            let start = trimmed.index(trimmed.startIndex, offsetBy: 2)
            let domain = String(trimmed[start..<domainEnd])
            return domain.isEmpty ? nil : domain
        }
        
        // TODO: Добавить парсинг других форматов правил
        return nil
    }
    
    private static func convertDomainsToSafariRules(_ domains: [String]) -> [String] {
        print("🔄 Начинаем конвертацию \(domains.count) доменов в правила Safari...")
        
        var preparedRules = [String]()
        let chunks = domains.chunked(by: 40000)
        
        print("📦 Разделено на чанки: \(chunks.count) по 40000 доменов")
        
        chunks.enumerated().forEach { index, chunk in
            print("🔄 Обрабатываем чанк \(index + 1)/\(chunks.count) с \(chunk.count) доменами")
            
            let rules = chunk.map(createSafariRule)
            let safariRulesArray = rules.isEmpty ? [createEmptyRule()] : rules
            
            print("📋 Создано правил Safari: \(safariRulesArray.count)")
            
            if let jsonString = convertRulesToJSON(safariRulesArray) {
                preparedRules.append(jsonString)
                print("✅ Чанк \(index + 1) конвертирован в JSON")
            } else {
                print("❌ Ошибка конвертации чанка \(index + 1) в JSON")
            }
        }
        
        print("✅ Конвертация завершена. Подготовлено файлов: \(preparedRules.count)")
        return preparedRules
    }
    
    private static func createSafariRule(from domain: String) -> [String: Any] {
        return [
            "trigger": [
                "url-filter": ".*\\b\(domain)\\b.*",
                "resource-type": ["script", "image", "subdocument"],
                "load-type": ["third-party", "first-party"]
            ],
            "action": ["type": "block"]
        ]
    }
    
    private static func createEmptyRule() -> [String: Any] {
        print("⚠️ Создаем пустое правило")
        return [
            "trigger": ["url-filter": "none"],
            "action": ["type": "block"]
        ]
    }
    
    private static func convertRulesToJSON(_ rules: [[String: Any]]) -> String? {
        let jsonString = JSON(rules).rawString(.utf8, options: .prettyPrinted)
        if jsonString != nil {
            print("✅ Правила конвертированы в JSON")
        } else {
            print("❌ Ошибка конвертации правил в JSON")
        }
        return jsonString
    }
    
    private static func saveRulesToFiles(_ preparedRules: [String]) {
        print("🔄 Начинаем сохранение правил в файлы...")
        print("📁 Количество подготовленных правил: \(preparedRules.count)")
        print("📁 Количество типов расширений: \(RulesType.allCases.count)")
        
        for (index, ruleType) in RulesType.allCases.enumerated() {
            print("🔄 Сохраняем правила для \(ruleType.rawValue) (индекс \(index))")
            
            if let rules = preparedRules[safe: index] {
                ruleType.writeRules(rules)
                print("✅ Правила для \(ruleType.rawValue) сохранены")
            } else {
                print("⚠️ Нет правил для \(ruleType.rawValue), создаем пустое правило")
                let emptyRuleArray = [createEmptyRule()]
                if let jsonString = convertRulesToJSON(emptyRuleArray) {
                    ruleType.writeRules(jsonString)
                    print("✅ Пустое правило для \(ruleType.rawValue) сохранено")
                } else {
                    print("❌ Ошибка сохранения пустого правила для \(ruleType.rawValue)")
                }
            }
        }
        
        print("✅ Сохранение правил завершено")
    }
}

extension Array {
    public func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}



// MARK: - Error Types

private enum RulesConverterError: Error {
    case fileNotFound
}
