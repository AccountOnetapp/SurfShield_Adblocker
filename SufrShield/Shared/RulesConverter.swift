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
    private var workItem: DispatchWorkItem?
    
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
            await shared.generateFiles()
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
                await reloadExtensions(bundles: [Constants.BlockExtenesionBundleIds.adblocker.rawValue], maxRetries: 1)
            } else {
                print("❌ Не удалось сохранить тестовые правила")
            }
            
        } catch {
            print("❌ Ошибка при работе с тестовыми правилами: \(error)")
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
            await generateFiles()
        } else {
            await generateEmptyRules()
        }
    }
    
    /// Применяет новое состояние и сохраняет его
    /// - Parameter isEnabled: новое состояние блокировщика
    public func applyNewState(isEnabled: Bool) async {
        print("🔄 Применяем новое состояние блокировщика: \(isEnabled ? "включен" : "выключен")")
        
        // Сохраняем новое состояние
        await AdBlockerStateManager.saveState(isEnabled)
        
        // Применяем новое состояние
        await applyBlockingState(isEnabled)
    }
    
    /// Генерирует пустые правила для отключения блокировки
    private func generateEmptyRules() async {
        workItem?.cancel()
        
        await withCheckedContinuation { continuation in
        let currentWorkItem = DispatchWorkItem {
                print("🔄 Создаем пустые правила для отключения блокировки...")
                
                let emptyRuleArray = [self.createEmptyRule()]
                
                guard let emptyRulesJSON = self.convertRulesToJSON(emptyRuleArray) else {
                    print("❌ Ошибка создания пустых правил")
                    continuation.resume()
                    return
                }
                
                for ruleType in RulesType.allCases {
                    ruleType.writeRules(emptyRulesJSON, groupID: self.groupID)
                    print("✅ Пустые правила сохранены для \(ruleType.rawValue)")
                }
                
                Task { @MainActor in
                    print("🔄 Перезагружаем расширения после создания пустых правил...")
                    await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
                    print("✅ Пустые правила применены ко всем расширениям")
                    continuation.resume()
                }
            }
            
            self.workItem = currentWorkItem
            DispatchQueue.global(qos: .userInteractive).async(execute: currentWorkItem)
        }
    }
    
    /// Генерирует файлы правил
    private func generateFiles() async {
        workItem?.cancel()
        
        await withCheckedContinuation { continuation in
            let currentWorkItem = DispatchWorkItem {
                do {
                    let domains = try self.loadAndParseDomains()
                    let preparedRules = self.convertDomainsToSafariRules(domains)
                    self.saveRulesToFiles(preparedRules)
                    
                    Task { @MainActor in
                        print("🔄 Перезагружаем расширения после создания правил блокировки...")
                        await self.reloadExtensions(bundles: self.extensionsBundles, maxRetries: self.extensionsBundles.count)
                        print("✅ Правила блокировки применены ко всем расширениям")
                        continuation.resume()
                    }
                } catch {
                    print("❌ Ошибка генерации файлов: \(error)")
                    continuation.resume()
                }
            }
            
            self.workItem = currentWorkItem
        DispatchQueue.global(qos: .userInteractive).async(execute: currentWorkItem)
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
        
        #if targetEnvironment(simulator)
        print("⚠️ Content Blocker Extensions не поддерживаются в симуляторе")
        return
        #endif
        
        guard #available(iOS 9.0, *) else {
            print("⚠️ SFContentBlockerManager недоступен на этой версии iOS")
            return 
        }
        
        for bundle in bundles {
            await withCheckedContinuation { continuation in
            SFContentBlockerManager.reloadContentBlocker(withIdentifier: bundle) { error in
                    if let error = error {
                        print("❌ Ошибка перезагрузки расширения \(bundle): \(error.localizedDescription)")
                    } else {
                        print("✅ Расширение \(bundle) успешно перезагружено")
                    }
                    continuation.resume()
                }
            }
        }
    }
    
    private func loadAndParseDomains() throws -> [String] {
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
        guard let filePath = getFilePath(groupID: groupID) else { return }
        let fileManager = FileManager.default
        
        try? rules.write(to: filePath, atomically: true, encoding: .utf8)
        
        if fileManager.fileExists(atPath: filePath.path) {
            print("\(self.rawValue) successfully write to file", filePath.absoluteURL)
        } else {
            print("\(self.rawValue) cant write to file with path \(filePath.absoluteURL)")
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

struct AdBlockRuleParser {
    struct ParsedRule {
        let urlFilter: String
        let action: Action
        let resourceTypes: [String]
        let loadTypes: [String]
        let unlessDomains: [String]
        let ifDomains: [String]
        
        enum Action {
            case block
            case allow
        }
    }
    
    static func parse(_ rule: String) -> ParsedRule? {
        var workingRule = rule
        var action: ParsedRule.Action = .block
        var resourceTypes: [String] = []
        var loadTypes: [String] = []
        var unlessDomains: [String] = []
        var ifDomains: [String] = []
        
        // Проверяем на исключение (@@)
        if workingRule.hasPrefix("@@") {
            action = .allow
            workingRule = String(workingRule.dropFirst(2))
        }
        
        // Разделяем на URL и опции
        let parts = workingRule.components(separatedBy: "$")
        let urlPart = parts[0]
        let optionsPart = parts.count > 1 ? parts[1] : ""
        
        // Парсим опции
        if !optionsPart.isEmpty {
            let options = optionsPart.components(separatedBy: ",")
            
            for option in options {
                let trimmedOption = option.trimmingCharacters(in: .whitespaces)
                
                if trimmedOption == "third-party" {
                    loadTypes.append("third-party")
                } else if trimmedOption == "first-party" {
                    loadTypes.append("first-party")
                } else if trimmedOption.hasPrefix("domain=") {
                    let domainString = String(trimmedOption.dropFirst(7))
                    let domains = domainString.components(separatedBy: "|")
                    
                    for domain in domains {
                        if domain.hasPrefix("~") {
                            unlessDomains.append(String(domain.dropFirst(1)))
                        } else {
                            ifDomains.append(domain)
                        }
                    }
                } else if isResourceType(trimmedOption) {
                    if trimmedOption.hasPrefix("~") {
                        // Исключаем этот тип ресурса - добавляем все остальные
                        let excludedType = String(trimmedOption.dropFirst(1))
                        resourceTypes = getAllResourceTypes().filter { $0 != mapResourceType(excludedType) }
                    } else {
                        resourceTypes.append(mapResourceType(trimmedOption))
                    }
                }
            }
        }
        
        // Конвертируем URL в Safari формат
        let urlFilter = convertUrlToSafariFilter(urlPart)
        
        return ParsedRule(
            urlFilter: urlFilter,
            action: action,
            resourceTypes: resourceTypes,
            loadTypes: loadTypes,
            unlessDomains: unlessDomains,
            ifDomains: ifDomains
        )
    }
    
    private static func convertUrlToSafariFilter(_ url: String) -> String {
        var filter = url
        
        // Обрабатываем специальные символы AdBlock СНАЧАЛА
        if filter.hasPrefix("||") {
            // ||domain^ -> ^https?://.*domain.*
            filter = String(filter.dropFirst(2)) // убираем ||
            if filter.hasSuffix("^") {
                filter = String(filter.dropLast(1)) // убираем ^
            }
            // Экранируем точки в доменах
            filter = filter.replacingOccurrences(of: ".", with: "\\.")
            filter = "^https?://.*" + filter + ".*"
        } else if filter.hasPrefix("/") && filter.hasSuffix("/") {
            // /path/ -> ^https?://.*/path.*
            filter = String(filter.dropFirst().dropLast()) // убираем / /
            filter = escapeRegexCharacters(filter)
            filter = "^https?://.*/" + filter + ".*"
        } else {
            // Обычный URL или путь
            filter = escapeRegexCharacters(filter)
            if !filter.hasPrefix("^https?://") {
                filter = "^https?://.*" + filter + ".*"
            }
        }
        
        return filter
    }
    
    private static func escapeRegexCharacters(_ string: String) -> String {
        // Экранируем только необходимые символы для Safari
        var escaped = string
        escaped = escaped.replacingOccurrences(of: "\\", with: "\\\\")
        escaped = escaped.replacingOccurrences(of: ".", with: "\\.")
        escaped = escaped.replacingOccurrences(of: "+", with: "\\+")
        escaped = escaped.replacingOccurrences(of: "?", with: "\\?")
        escaped = escaped.replacingOccurrences(of: "$", with: "\\$")
        escaped = escaped.replacingOccurrences(of: "{", with: "\\{")
        escaped = escaped.replacingOccurrences(of: "}", with: "\\}")
        escaped = escaped.replacingOccurrences(of: "[", with: "\\[")
        escaped = escaped.replacingOccurrences(of: "]", with: "\\]")
        escaped = escaped.replacingOccurrences(of: "(", with: "\\(")
        escaped = escaped.replacingOccurrences(of: ")", with: "\\)")
        return escaped
    }
    
    private static func isResourceType(_ option: String) -> Bool {
        let cleanOption = option.hasPrefix("~") ? String(option.dropFirst(1)) : option
        let resourceTypes = ["script", "image", "stylesheet", "object", "xmlhttprequest", 
                           "subdocument", "ping", "websocket", "other", "font", "media"]
        return resourceTypes.contains(cleanOption)
    }
    
    private static func mapResourceType(_ type: String) -> String {
        switch type {
        case "stylesheet": return "style-sheet"
        case "xmlhttprequest": return "raw"
        case "other": return "raw"
        default: return type
        }
    }
    
    private static func getAllResourceTypes() -> [String] {
        return ["script", "image", "style-sheet", "font", "raw", "media"]
    }
}
