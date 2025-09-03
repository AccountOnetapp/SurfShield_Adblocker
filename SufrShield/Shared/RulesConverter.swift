//
//  RulesConverter.swift
//  SufrShield
//
//  Created by Артур Кулик on 25.08.2025.
//
import Foundation
import SafariServices


/// Модуль блокировщика рекламы
public class RulesConverter {
    // MARK: - Singleton
    public static let shared = RulesConverter()
    
    // MARK: Internal Properties
    private let groupID: String = Constants.adblockGroupId
    private let extensionsBundles: [String] = Constants.BlockExtenesionBundleIds.all
    
    // MARK: - Initialization
    private init() {
        print("🚀 Создаем RulesConverter singleton...")
        Task {
            await initialize()
        }
    }
    
    // MARK: - Static API (обертки для singleton)
    
    /// Получить URL файла правил с fallback к bundle
    /// - Parameter type: тип расширения
    /// - Returns: URL файла правил или fallback к bundle
    public static func getExtensionFileURLWithFallback(forType type: RulesType) -> URL? {
        return type.filePath
    }
    
    /// Переключает состояние блокировщика
    public static func toggleBlocking() async {
        await shared.toggleBlocking()
    }
    
    /// Включает блокировщик
    public static func enableBlocking() async {
        await shared.enableBlocking()
    }
    
    /// Выключает блокировщик
    public static func disableBlocking() async {
        await shared.disableBlocking()
    }
    
    /// Получает текущее состояние блокировщика
    public static func isBlockingEnabled() async -> Bool {
        return await shared.isBlockingEnabled()
    }
    
    /// Диагностика Content Blocker API
    public static func diagnoseContentBlocker() {
        shared.diagnoseContentBlocker()
    }
    
    /// Тестовый метод для проверки состояния блокировщика
    public static func testBlockerState() async {
        await shared.testBlockerState()
    }
    
    /// Простой тестовый метод для загрузки готовых правил
    public static func loadTestRules() async {
        await shared.loadTestRules()
    }
    
    /// Применяет текущее состояние блокировщика при запуске
    public static func applyBlockingState(_ isEnabled: Bool) async {
        await shared.applyBlockingState(isEnabled)
    }
    
    /// Применяет новое состояние и сохраняет его
    /// - Parameter isEnabled: новое состояние блокировщика
    public static func applyNewState(isEnabled: Bool) async {
        await shared.applyNewState(isEnabled: isEnabled)
    }
    
    /// Инициализирует блокировщик с текущим сохраненным состоянием
    public static func initialize() async {
        await shared.initialize()
    }
    
    /// Старый метод для совместимости
    public static func start() {
        Task {
//            await shared.generateFiles()
        }
    }
    
    // MARK: - Public Methods
    
    /// Переключает состояние блокировщика
    public func toggleBlocking() async {
        let currentState = await AdBlockerStateManager.getCurrentState()
        let newState = !currentState
        
        print("🔄 Переключаем блокировщик: \(currentState ? "выключаем" : "включаем")")
        
        // Сохраняем новое состояние
        await AdBlockerStateManager.saveState(newState)
        
        // Применяем новое состояние
        await applyBlockingState(newState)
    }
    
    /// Включает блокировщик
    public func enableBlocking() async {
        print("🔄 Включаем блокировщик")
        await AdBlockerStateManager.saveState(true)
        await applyBlockingState(true)
    }
    
    /// Выключает блокировщик
    public func disableBlocking() async {
        print("🔄 Выключаем блокировщик")
        await AdBlockerStateManager.saveState(false)
        await applyBlockingState(false)
    }
    
    /// Получает текущее состояние блокировщика
    public func isBlockingEnabled() async -> Bool {
        return await AdBlockerStateManager.getCurrentState()
    }
    
    /// Диагностика Content Blocker API
    public func diagnoseContentBlocker() {
        print("🔍 Диагностика Content Blocker API...")
        
        #if targetEnvironment(simulator)
        print("⚠️ Запущено в симуляторе - Content Blocker Extensions не поддерживаются")
        #else
        print("✅ Запущено на реальном устройстве")
        #endif
        
        if #available(iOS 9.0, *) {
            print("✅ iOS версия поддерживает Content Blocker")
            
            // Проверяем доступность класса
            let managerClass = SFContentBlockerManager.self
            print("✅ Класс SFContentBlockerManager доступен: \(managerClass)")
            
        } else {
            print("❌ iOS версия не поддерживает Content Blocker")
        }
        
        print("📦 Bundle IDs расширений:")
        for bundle in extensionsBundles {
            print("  - \(bundle)")
        }
    }
    
    /// Тестовый метод для проверки состояния блокировщика
    public func testBlockerState() async {
        let currentState = await AdBlockerStateManager.getCurrentState()
        print("🧪 Тестируем состояние блокировщика...")
        print("📱 Текущее состояние: \(currentState ? "включен" : "выключен")")
        
        // Диагностика
        diagnoseContentBlocker()
        
        // Применяем текущее состояние
        await applyBlockingState(currentState)
    }
    
    /// Простой тестовый метод для загрузки готовых правил
    public func loadTestRules() async {
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
            let targetFileURL = groupURL.appendingPathComponent("adBlock.json")
            try testRulesString.write(to: targetFileURL, atomically: true, encoding: .utf8)
            
            if fileManager.fileExists(atPath: targetFileURL.path) {
                print("✅ Тестовые правила сохранены в App Group: \(targetFileURL.path)")
                
                // Перезагружаем расширения
                await reloadExtensions(bundles: [Constants.BlockExtenesionBundleIds.adblocker.rawValue], maxRetries: 4)
            } else {
                print("❌ Не удалось сохранить тестовые правила")
            }
            
        } catch {
            print("❌ Ошибка при работе с тестовыми правилами: \(error)")
        }
    }
    
    //MARK: Main Method
    public func enableContentBlocker() async  {
        guard let rulesPath = Bundle.main.path(forResource: "adblock_rules2", ofType: "txt") else {
            print("❌ Файл adblock_rules2.txt не найден в bundle")
            return
        }
        
        print("🔄 Начинаем загрузку и конвертацию правил...")
        
        let rulesString = try! String(contentsOfFile: rulesPath, encoding: .utf8)
        let lines = rulesString.components(separatedBy: .newlines)
        let chunkedRules = lines.chunked(by: 180000)
        var resultArray: [String] = []
        
        print("📊 Обрабатываем \(lines.count) правил, разбитых на \(chunkedRules.count) чанков")
        
        for (index, chunkedRule) in chunkedRules.enumerated() {
            print("🔄 Обрабатываем чанк \(index + 1)/\(chunkedRules.count)...")
            
            let result: ConversionResult = ContentBlockerConverter().convertArray(
                   rules: chunkedRule,
                   safariVersion: SafariVersion.autodetect(),
                   advancedBlocking: true,
                   maxJsonSizeBytes: nil,
                   progress: nil
               )
            let json = result.safariRulesJSON
            resultArray.append(json)
            
            // Сохраняем JSON в файл для просмотра
            saveJSONToFile(json: json)
        }
        
        print("💾 Сохраняем правила в App Group...")
        // ВАЖНО: Сначала сохраняем правила в App Group
        RulesConverter.shared.saveRulesToFiles(resultArray)
        
        // Небольшая задержка для гарантии записи на диск
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
        
        print("🔄 Перезагружаем расширения после сохранения правил...")
        // Только после сохранения перезагружаем расширения
        await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
        
        print("✅ Загружено \(lines.count) правил из adblock_rules2.txt и применено ко всем расширениям")
    }
    
    /// Сохраняет JSON в файл для просмотра
    private func saveJSONToFile(json: String) {
        do {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = "safari_rules_\(Date().timeIntervalSince1970).json"
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            try json.write(to: fileURL, atomically: true, encoding: .utf8)
            
            print("💾 JSON сохранен в файл: \(fileURL.path)")
            print("📁 Путь к файлу: \(fileURL.path)")
            
        } catch {
            print("❌ Ошибка при сохранении JSON: \(error)")
        }
    }
 
    // MARK: - Private Methods
    
    /// Инициализирует блокировщик с текущим сохраненным состоянием
    private func initialize() async {
        let currentState = await AdBlockerStateManager.getCurrentState()
        print("🚀 Инициализируем блокировщик с состоянием: \(currentState ? "включен" : "выключен")")
        await applyBlockingState(currentState)
    }
    
    /// Применяет или отменяет правила блокировки в зависимости от состояния
    private func applyBlockingState(_ isEnabled: Bool) async {
        print("🔄 Применяем состояние блокировщика: \(isEnabled ? "включен" : "выключен")")
        
        if isEnabled {
//            await generateFiles()
            await enableContentBlocker()
        } else {
            await generateEmptyRules()
        }
    }
    
    /// Применяет новое состояние и сохраняет его
    /// - Parameter isEnabled: новое состояние блокировщика
    public func applyNewState(isEnabled: Bool) async {
        print("🔄 Применяем новое состояние блокировщика: \(isEnabled ? "включен" : "выключен")")
        
        
        // Применяем новое состояние
        await applyBlockingState(isEnabled)
        // Сохраняем новое состояние
        await AdBlockerStateManager.saveState(isEnabled)
    }
    
    /// Генерирует пустые правила для отключения блокировки
    private func generateEmptyRules() async {
        print("🔄 Создаем пустые правила для отключения блокировки...")
        
        let emptyRuleArray = [self.createEmptyRule()]
        
        guard let emptyRulesJSON = self.convertRulesToJSON(emptyRuleArray) else {
            print("❌ Ошибка создания пустых правил")
            return
        }
        
        print("💾 Сохраняем пустые правила в App Group...")
        for ruleType in RulesType.allCases {
            ruleType.writeRules(emptyRulesJSON, groupID: self.groupID)
            print("✅ Пустые правила сохранены для \(ruleType.rawValue)")
        }
        
        // Небольшая задержка для гарантии записи на диск
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
        
        print("🔄 Перезагружаем расширения после создания пустых правил...")
        await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
        print("✅ Пустые правила применены ко всем расширениям")
    }
    
    /// Генерирует файлы правил
    private func generateFiles() async {
        do {
            let domains = try self.loadAndParseDomains()
            let preparedRules = self.convertDomainsToSafariRules(domains)
            self.saveRulesToFiles(preparedRules)
            
            print("🔄 Перезагружаем расширения после создания правил блокировки...")
            await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
            print("✅ Правила блокировки применены ко всем расширениям")
        } catch {
            print("❌ Ошибка генерации файлов: \(error)")
        }
    }
    
    // Добавляем недостающие вспомогательные методы
    private func createEmptyRule() -> [String: Any] {
        return [
            "trigger": [
                "url-filter": "^https?://never-existing-domain-for-adblocker-disabled\\.com/.*"
            ],
            "action": [
                "type": "block"
            ]
        ]
    }
    
    private func convertRulesToJSON(_ rules: [[String: Any]]) -> String? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: rules, options: .prettyPrinted)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("❌ Ошибка конвертации правил в JSON: \(error)")
            return nil
        }
    }
    
    private func reloadExtensions(bundles: [String], maxRetries: Int) async {
        guard !bundles.isEmpty else { return }
        
        print("🔄 Начинаем параллельную перезагрузку \(bundles.count) расширений...")
        
        // Создаем задачи для параллельной перезагрузки всех расширений
//        let reloadTasks = bundles.map { bundle in
//            Task {
//                await reloadSingleExtension(bundle: bundle, maxRetries: maxRetries)
//            }
//        }
        
        for bundle in bundles {
            await reloadSingleExtension(bundle: bundle, maxRetries: 1)
        }
        
        // Ждем завершения всех задач
//        await withTaskGroup(of: Void.self) { group in
//            for task in reloadTasks {
//                group.addTask {
//                    await task.value
//                }
//            }
//        }
        
        print("✅ Завершена перезагрузка всех расширений")
    }
    
    /// Перезагружает одно расширение с повторными попытками
    private func reloadSingleExtension(bundle: String, maxRetries: Int) async {
        var attempts = 0
        
        while attempts < maxRetries {
            attempts += 1
            
            print("DEBUG: ATTEMPT TO RELOAD Blocker for \(bundle)")
            do {
                try await SFContentBlockerManager.reloadContentBlocker(withIdentifier: bundle)
                print("✅ Расширение \(bundle) успешно перезагружено (попытка \(attempts)/\(maxRetries))")
                return
            } catch {
                print("❌ Попытка - Ошибка перезагрузки расширения \(bundle):")
            }

            // Небольшая задержка перед повторной попыткой
            if attempts < maxRetries {
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 секунды
            }
        }
        
        print("⚠️ Не удалось перезагрузить расширение \(bundle) после \(maxRetries) попыток")
    }
    
    func loadAndParseDomains() throws -> [String] {
        guard let rulesPath = Bundle.main.path(forResource: "domains", ofType: "txt") else {
            throw RulesConverterError.fileNotFound
        }
        
        let rulesString = try String(contentsOfFile: rulesPath, encoding: .utf8)
        let lines = rulesString.components(separatedBy: .newlines)
        return lines.compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("!"), !trimmed.hasPrefix("[") else { return nil }
            guard !trimmed.contains("##") else { return nil }
            return trimmed
        }
    }
    
    private func convertDomainsToSafariRules(_ rules: [String]) -> [String] {
        let chunks = rules.chunked(by: 35000)
        var preparedRules = [String]()
        
        for chunk in chunks {
            let safariRules = chunk.compactMap { domain in
                let escapedDomain = domain.replacingOccurrences(of: ".", with: "\\.")
                return [
                    "trigger": [
                        "url-filter": "^https?:/+([^/:]+\\.)?\(escapedDomain)[:/]",
                        "load-type": ["third-party", "first-party"]
                    ],
                    "action": ["type": "block"]
                ]
            }
            
            if let jsonString = convertRulesToJSON(safariRules.isEmpty ? [createEmptyRule()] : safariRules) {
                preparedRules.append(jsonString)
            }
        }
        
        return preparedRules
    }
    
    private func saveRulesToFiles(_ preparedRules: [String]) {
        for (index, ruleType) in RulesType.allCases.enumerated() {
            if let rules = preparedRules[safe: index] {
                ruleType.writeRules(rules, groupID: groupID)
            } else {
                let emptyRuleArray = [createEmptyRule()]
                if let jsonString = convertRulesToJSON(emptyRuleArray) {
                    ruleType.writeRules(jsonString, groupID: groupID)
                }
            }
        }
    }
}


/// Тип екстеншена блокировщика
public enum RulesType: String, Codable, CaseIterable {
    case adBlock
    case sequrity
    case privacy
    case banners
    case trackers
    case advanced
    case secure
    case basic
    
    /// Получить URL по каторому находится файл для определенного экстеншна
    /// - Returns: URL по каторому находится файл
    internal var filePath: URL? {
        let fileManager = FileManager.default
        // Используй App Group вместо Documents
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Constants.adblockGroupId) else {
            return nil
        }
        let fileURL = groupURL.appendingPathComponent("\(self.rawValue).json")
        return fileURL
    }
    
    private var fileName: String {
        return self.rawValue + ".json"
    }

    internal func writeRules(_ rules: String, groupID: String) {
        guard let filePath = getFilePath(groupID: groupID) else { 
            print("❌ Не удалось получить путь для \(self.rawValue)")
            return 
        }
        let fileManager = FileManager.default
        
        do {
            // Синхронная запись с принудительной синхронизацией
            try rules.write(to: filePath, atomically: true, encoding: .utf8)
            
            // Принудительная синхронизация файловой системы
            let fileHandle = try FileHandle(forWritingTo: filePath)
            try fileHandle.synchronize()
            try fileHandle.close()
            
            // Проверяем, что файл действительно создался и имеет правильный размер
            if fileManager.fileExists(atPath: filePath.path) {
                let attributes = try? fileManager.attributesOfItem(atPath: filePath.path)
                let fileSize = attributes?[.size] as? Int64 ?? 0
                print("✅ \(self.rawValue) успешно сохранен: \(filePath.path) (размер: \(fileSize) байт)")
            } else {
                print("❌ \(self.rawValue) файл не найден после записи: \(filePath.path)")
            }
        } catch {
            print("❌ Ошибка записи \(self.rawValue): \(error.localizedDescription)")
        }
    }
    
    private func getFilePath(groupID: String) -> URL? {
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            return nil
        }
        let fileURL = groupURL.appendingPathComponent("\(self.rawValue).json")
        return fileURL
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

// MARK: - AdBlock Rule Parser

