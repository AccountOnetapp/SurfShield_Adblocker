import Foundation
import SafariServices

class ContentBlockerService {
    private let groupID: String = Constants.adblockGroupId
    private let extensionsBundles: String = Constants.BlockExtenesionBundleIds.adblocker.rawValue
    private let maxRules = 150000 // Лимит правил для Safari
    
    var fileName: String {
        return "domains"
    }
    
    var filePath: String {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "txt") else { return "" }
        return path
    }
    
    /// Получить URL файла правил с fallback к bundle
    /// Используется в расширениях
    func getExtensionFileURLWithFallback(forType type: RulesType) -> URL? {
        return getFilePath(groupID: groupID)
    }
    
    func enableBlocker(isOn: Bool) async {
        print("\n" + String(repeating: "=", count: 60))
        print("🛡️  БЛОКИРОВЩИК РЕКЛАМЫ: \(isOn ? "ВКЛЮЧЕНИЕ" : "ОТКЛЮЧЕНИЕ")")
        print(String(repeating: "=", count: 60))
        
        if isOn {
            await enable()
        } else {
            await disable()
        }
    }
    
    func enable() async {
        print("✅ СТАТУС: Включаем блокировщик рекламы...")
        print("📍 Путь к файлу правил: \(filePath)")
        
        guard !filePath.isEmpty else {
            print("❌ ОШИБКА: Файл domains.txt не найден")
            print("❌ СТАТУС: Блокировщик НЕ ВКЛЮЧЕН (ошибка загрузки файла)")
            return
        }
        
        print("📖 Читаем файл с доменами...")
        let rulesString = try! String(contentsOfFile: filePath, encoding: .utf8)
        let lines = rulesString.components(separatedBy: .newlines)
            .filter { !$0.isEmpty }
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        // Ограничиваем количество правил лимитом Safari
        let limitedLines = Array(lines.prefix(maxRules))
        
        print("📊 ИНФОРМАЦИЯ: Всего доменов в файле: \(lines.count)")
        print("📊 ИНФОРМАЦИЯ: Будет создано правил: \(limitedLines.count) (лимит: \(maxRules))")
        if lines.count > maxRules {
            print("⚠️  ВНИМАНИЕ: Количество доменов превышает лимит, будут использованы первые \(maxRules)")
        }
        print("🔄 Начинаем конвертацию доменов в правила блокировки...")
        
        var rules = [[String:Any]]()
        
        for line in limitedLines {
            // Экранируем специальные символы в домене для regex
            let escapedDomain = NSRegularExpression.escapedPattern(for: line)
            
            let rule = [
                "trigger" : [
                    "url-filter": "^https?:/+([^/:]+\\.)?\(escapedDomain)[:/]",
                    "load-type": [
                        "third-party",
                        "first-party"
                    ]
                ],
                "action": [
                    "type": "block"
                ]
            ] as [String : Any]
            
            rules.append(rule)
        }
        
        print("✅ Конвертация завершена: создано \(rules.count) правил")
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: rules, options: [.prettyPrinted]),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ ОШИБКА: Не удалось конвертировать правила в JSON")
            print("❌ СТАТУС: Блокировщик НЕ ВКЛЮЧЕН (ошибка конвертации)")
            return
        }
        
        print("💾 Размер JSON данных: \(jsonData.count) байт")
        
        // Используем getFilePath для получения правильного пути к файлу
        guard let fileURL = getFilePath(groupID: groupID) else {
            print("❌ ОШИБКА: Не удалось получить путь к App Group")
            print("❌ СТАТУС: Блокировщик НЕ ВКЛЮЧЕН (ошибка доступа к App Group)")
            return
        }
        
        print("📁 Сохраняем правила в: \(fileURL.path)")
        let fileManager = FileManager.default
        
        do {
            // Сохраняем JSON строку в файл
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Принудительная синхронизация файловой системы
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            try fileHandle.synchronize()
            try fileHandle.close()
            
            // Проверяем, что файл действительно создался
            if fileManager.fileExists(atPath: fileURL.path) {
                let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path)
                let fileSize = attributes?[.size] as? Int64 ?? 0
                print("✅ Файл успешно сохранен")
                print("   📊 Размер файла: \(fileSize) байт (\(String(format: "%.2f", Double(fileSize) / 1024.0)) KB))")
                print("   📊 Количество правил в файле: \(rules.count)")
            } else {
                print("❌ ОШИБКА: Файл не найден после записи")
                print("❌ СТАТУС: Блокировщик НЕ ВКЛЮЧЕН (ошибка сохранения)")
                return
            }
            
            // Перезагружаем расширение
            print("🔄 Перезагружаем расширение adBlock...")
            print("   📦 Bundle ID: \(extensionsBundles)")
            try await SFContentBlockerManager.reloadContentBlocker(withIdentifier: extensionsBundles)
            print("✅ Расширение успешно перезагружено")
            
            print("\n" + String(repeating: "=", count: 60))
            print("✅ СТАТУС: БЛОКИРОВЩИК РЕКЛАМЫ ВКЛЮЧЕН")
            print("   📊 Активных правил: \(rules.count)")
            print("   📁 Файл правил: \(fileURL.path)")
            print("   📦 Расширение: \(extensionsBundles)")
            print(String(repeating: "=", count: 60) + "\n")
            
        } catch {
            print("❌ ОШИБКА: \(error.localizedDescription)")
            print("❌ СТАТУС: Блокировщик НЕ ВКЛЮЧЕН (ошибка: \(error))")
            print(String(repeating: "=", count: 60) + "\n")
        }
    }
    
    func disable() async {
        print("❌ СТАТУС: Отключаем блокировщик рекламы...")
        
        // Создаем пустое правило для отключения блокировщика
        let emptyRules = [[
            "trigger": [
                "url-filter": "^https?://never-existing-domain-for-adblocker-disabled\\.com/.*"
            ],
            "action": [
                "type": "block"
            ]
        ] as [String : Any]]
        
        print("🔄 Создаем пустые правила для отключения...")
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: emptyRules, options: [.prettyPrinted]),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ ОШИБКА: Не удалось создать пустые правила")
            print("❌ СТАТУС: Блокировщик НЕ ОТКЛЮЧЕН (ошибка создания правил)")
            return
        }
        
        guard let fileURL = getFilePath(groupID: groupID) else {
            print("❌ ОШИБКА: Не удалось получить путь к App Group")
            print("❌ СТАТУС: Блокировщик НЕ ОТКЛЮЧЕН (ошибка доступа к App Group)")
            return
        }
        
        print("📁 Сохраняем пустые правила в: \(fileURL.path)")
        let fileManager = FileManager.default
        
        do {
            // Сохраняем пустые правила
            try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
            
            // Принудительная синхронизация файловой системы
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            try fileHandle.synchronize()
            try fileHandle.close()
            
            if fileManager.fileExists(atPath: fileURL.path) {
                let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path)
                let fileSize = attributes?[.size] as? Int64 ?? 0
                print("✅ Пустые правила сохранены")
                print("   📊 Размер файла: \(fileSize) байт")
                print("   📊 Количество правил: 1 (пустое правило)")
            } else {
                print("❌ ОШИБКА: Файл не найден после записи")
                print("❌ СТАТУС: Блокировщик НЕ ОТКЛЮЧЕН (ошибка сохранения)")
                return
            }
            
            // Перезагружаем расширение
            print("🔄 Перезагружаем расширение adBlock...")
            print("   📦 Bundle ID: \(extensionsBundles)")
            try await SFContentBlockerManager.reloadContentBlocker(withIdentifier: extensionsBundles)
            print("✅ Расширение успешно перезагружено")
            
            print("\n" + String(repeating: "=", count: 60))
            print("❌ СТАТУС: БЛОКИРОВЩИК РЕКЛАМЫ ОТКЛЮЧЕН")
            print("   📊 Активных правил: 0 (пустое правило)")
            print("   📁 Файл правил: \(fileURL.path)")
            print("   📦 Расширение: \(extensionsBundles)")
            print(String(repeating: "=", count: 60) + "\n")
            
        } catch {
            print("❌ ОШИБКА: \(error.localizedDescription)")
            print("❌ СТАТУС: Блокировщик НЕ ОТКЛЮЧЕН (ошибка: \(error))")
            print(String(repeating: "=", count: 60) + "\n")
        }
    }
    
    private func getFilePath(groupID: String) -> URL? {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            return nil
        }
        let fileURL = groupURL.appendingPathComponent("adBlock.json")
        return fileURL
    }
}
public enum RulesType: String, Codable, CaseIterable {
    case adBlock
    case privacy
    case banners
    case trackers
    case advanced
    case secure
    case basic
}
