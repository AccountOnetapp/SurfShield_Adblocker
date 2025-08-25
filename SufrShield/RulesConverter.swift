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
    internal static var extensionsBundles: [String] = ["com.surfshield.app.adblocker","com.surfshield.app.security", "com.surfshield.app.privacy"]
    
    /// Получить URL по каторому находится файл для определенного экстеншна
    /// - Parameters:
    ///   - type: тип екстеншена, для которго нужно получить URL
    /// - Returns: URL по каторому находится файл
    public static func getExtensionFileURL(forType type: ExtensionType) -> URL? {
        return type.filePath
    }
}


/// Тип екстеншена блокировщика
public enum ExtensionType: String, Codable, CaseIterable  {
    case adware
    case sequrity
    case privacy
    
    //    internal var filePath: URL? {
    //        let fileManager = FileManager.default
    //        let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RulesConverter.groupID)
    //        let fileURL = groupURL?.appendingPathComponent(self.fileName)
    //        return fileURL
    //    }
    
    /// Получить URL по каторому находится файл для определенного экстеншна
    /// - Returns: URL по каторому находится файл
    internal var filePath: URL? {
        let fileManager = FileManager.default
        // Используй App Group вместо Documents
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RulesConverter.groupID) else {
            return nil
        }
        let fileURL = groupURL.appendingPathComponent("new_rules.json")
        return fileURL
    }
    
    private var fileName: String {
        return self.rawValue + ".json"
    }
    
    internal var filePathToCopy: URL? {
        let fileManager = FileManager.default
        let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: RulesConverter.groupID)
        let fileURL = groupURL?.appendingPathComponent(self.copyFileName)
        return fileURL
    }
    
    private var copyFileName: String {
        return self.rawValue + "Copy.json"
    }
    
    internal func writeRules(_ rules: String) {
        guard let filePath = filePath else { return }
        let fileManager = FileManager.default
        
        
        try? rules.write(to: filePath, atomically: true, encoding: .utf8)
        
        if fileManager.fileExists(atPath: filePath.path) {
            print("\(self.rawValue) successfully write to file", filePath.absoluteURL)
        } else {
            print("\(self.rawValue) cant write to file")
        }
    }
    
    // Шорткаты загружают копию, для генерации у них не хватает памяти
    internal func saveCopy(_ rules: String) {
        guard let filePath = filePathToCopy else { return }
        let fileManager = FileManager.default
        
        try? rules.write(to: filePath, atomically: true, encoding: .utf8)
        
        if fileManager.fileExists(atPath: filePath.path) {
            print("\(self.rawValue) successfully write to file", filePath.absoluteURL)
        } else {
            print("\(self.rawValue) cant write to file")
        }
    }
    
    internal func getCopy() -> String? {
        guard let filePath = filePathToCopy else { return nil }
        
        do {
            let data = try Data(contentsOf: filePath)
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error load copy \(error)")
            return nil
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
                    reloadExtensions(bundles: extensionsBundles, maxRetries: 3) {
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
            
            let bundle = Bundle.main
            guard let rulesPath = bundle.path(forResource: "adblock_rules", ofType: "txt") else {
                print("Файл не найден")
                return
            }
            
            // 2. Читаем содержимое файла
            let rulesString: String
            
            do {
                rulesString = try String(contentsOfFile: rulesPath, encoding: .utf8)
            } catch {
                print("Ошибка чтения файла: \(error)")
                return
            }
            
            // Здесь должен быть разбор EasyList в массив доменов, для примера:
            let lines = rulesString.components(separatedBy: .newlines)
            
            let domains = lines.compactMap { line -> String? in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty, !trimmed.hasPrefix("!"), !trimmed.hasPrefix("[") else { return nil }
                
                // Парсинг правил формата ||domain^
                if trimmed.hasPrefix("||"), let domainEnd = trimmed.firstIndex(of: "^") {
                    let start = trimmed.index(trimmed.startIndex, offsetBy: 2)
                    let domain = String(trimmed[start..<domainEnd])
                    return domain.isEmpty ? nil : domain
                }
                
                // Добавь парсинг других форматов правил
                // Например, правила вида .com/ads/, -banner-ads- и т.д.
                
                return nil
            }
            
            var preparedRules = [String]() // Массив для хранения подготовленных правил
            
            domains.chunked(by: 40000).forEach { chunk in
                var rules = [[String: Any]]() // Массив для хранения правил
                
                chunk.forEach { domain in
                    let rule: [String: Any] = [
                        "trigger": [
                            "url-filter": ".*\\b\(domain)\\b.*",
                            "resource-type": ["script", "image", "subdocument"],
                            "load-type": [
                                "third-party",
                                "first-party"
                            ]
                        ],
                        "action": ["type": "block"]
                    ]
                    
                    rules.append(rule)
                }
                print("DEBUG: rules count \(rules.count)")
                
                // Если массив правил пуст, добавляем пустое правило
                
                if rules.isEmpty {
                    let emptyRule: [String: Any] = ["trigger": ["url-filter": "none"], "action": ["type": "block"]]
                    rules = [emptyRule]
                }
                
                if let stringRules = JSON(rules).rawString(.utf8, options: .prettyPrinted) {
                    preparedRules.append(stringRules)
                }
            }
            
            
            for (index, file) in ExtensionType.allCases.enumerated() {
                if let rules = preparedRules[safe: index] { // Если правила для данного файла есть, записываем их
                    file.writeRules(rules)
                } else {
                    let emptyRule = [["trigger": ["url-filter": "none"], "action": ["type": "block"]]]  // Если правила для данного файла нет, записываем пустое правило
                    if let jsonData = try? JSONSerialization.data(withJSONObject: emptyRule, options: .prettyPrinted),
                       let jsonString = String(data: jsonData, encoding: .utf8) {
                        file.writeRules(jsonString)
                    }
                }
            }
            // Перезагружаем расширения
            DispatchQueue.main.async {
                reloadExtensions(bundles: extensionsBundles, maxRetries: 5, completion: completion)
            }
        }
        workItem = currentWorkItem
        DispatchQueue.global(qos: .userInteractive).async(execute: currentWorkItem)
    }
    
    
    private static func reloadExtensions(bundles: [String], maxRetries: Int, completion: @escaping () -> Void) {
        guard !bundles.isEmpty else { return }
        
        var reloadResults = [String: Bool]()
        
        for bundle in bundles {
            SFContentBlockerManager.reloadContentBlocker(withIdentifier: bundle) { error in
                reloadResults[bundle] = (error == nil)
                if reloadResults.count == bundles.count {
                    let failed = reloadResults.filter { !$0.value }
                    if failed.isEmpty || maxRetries <= 0 {
                        DispatchQueue.main.async { completion() }
                    } else {
                        reloadExtensions(bundles: failed.map { $0.key }, maxRetries: maxRetries - 1, completion: completion)
                    }
                }
            }
        }
    }
}

extension Array {
    //    func chunked(by chunkSize: Int) -> [[Element]] {
    //        var start = 0
    //        return (0..<self.count).reduce(into: [[Element]]()) { result, _ in
    //            let end = Swift.min(start + chunkSize, self.count)
    //            result.append(Array(self[start..<end]))
    //            start += chunkSize
    //        }
    //    }
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
