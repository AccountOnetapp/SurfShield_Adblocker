//
//  ContentBlockerAccepter.swift
//  Veilo
//
//  Created by Claude on 01.12.2025.
//

import Foundation
import SafariServices

/// Сервис для быстрого применения готовых JSON правил блокировки
/// Использует предварительно конвертированные правила из bundle,
/// минуя долгий процесс конвертации
final class ContentBlockerAccepter {
    
    // MARK: - Properties
    
    private let appGroupID: String
    private let ruleSets: [RuleSetInfo]
    private var currentTask: Task<Bool, Never>?
    
    // MARK: - Models
    
    struct RuleSetInfo {
        let identifier: String
        let extensionBundleID: String
        let jsonFileName: String
    }
    
    // MARK: - Initialization
    
    init(appGroupID: String, ruleSets: [RuleSetInfo]) {
        self.appGroupID = appGroupID
        self.ruleSets = ruleSets
    }
    
    // MARK: - Public Methods
    
    /// Применить правила блокировки (включить блокировщик)
    /// - Returns: true если успешно, false если произошла ошибка
    @discardableResult
    func applyBlockingRules() async -> Bool {
        // Отменяем предыдущую задачу если она есть
        currentTask?.cancel()
        
        // Создаем новую задачу
        let task = Task<Bool, Never> {
            print("🚀 ContentBlockerAccepter: Начало применения правил...")
            
            // Проверяем отмену
            guard !Task.isCancelled else {
                print("⚠️ Операция отменена")
                return false
            }
            
            // 1. Сохраняем все JSON файлы в AppGroup (синхронно)
            let saveResults = saveAllRulesToAppGroup()
            
            // Проверяем отмену после сохранения
            guard !Task.isCancelled else {
                print("⚠️ Операция отменена после сохранения")
                return false
            }
            
            print("✅ Все правила сохранены в AppGroup")
            
            // 2. Перезагружаем Safari расширения (асинхронно)
            await reloadAllExtensions()
            
            print("✅ Блокировщик применен!")
            return true
        }
        
        currentTask = task
        return await task.value
    }
    
    /// Отключить правила блокировки (выключить блокировщик)
    @discardableResult
    func disableBlockingRules() async -> Bool {
        // Отменяем предыдущую задачу если она есть
        currentTask?.cancel()
        
        // Создаем новую задачу
        let task = Task<Bool, Never> {
            print("🚫 ContentBlockerAccepter: Отключение блокировщика...")
            
            // Проверяем отмену
            guard !Task.isCancelled else {
                print("⚠️ Операция отменена")
                return false
            }
            
            // Записываем пустые правила (заглушки)
            let emptyRule = createEmptyRule()
            
            for ruleSet in ruleSets {
                guard !Task.isCancelled else {
                    print("⚠️ Операция отменена")
                    return false
                }
                
                if let fileURL = getAppGroupFileURL(for: ruleSet.identifier) {
                    do {
                        try emptyRule.write(to: fileURL, atomically: true, encoding: .utf8)
                        print("✅ Отключен \(ruleSet.identifier)")
                    } catch {
                        print("❌ Ошибка отключения \(ruleSet.identifier): \(error)")
                    }
                }
            }
            
            // Перезагружаем расширения
            await reloadAllExtensions()
            
            print("✅ Блокировщик отключен!")
            return true
        }
        
        currentTask = task
        return await task.value
    }
    
    /// Отменить все текущие операции
    func cancelAllOperations() {
        print("🛑 ContentBlockerAccepter: Отмена текущих операций...")
        currentTask?.cancel()
        currentTask = nil
    }
    
    // MARK: - Private Methods
    
    /// Сохраняет все правила в AppGroup
    private func saveAllRulesToAppGroup() -> [Bool] {
        var results: [Bool] = []
        
        for ruleSet in ruleSets {
            let result = saveRuleToAppGroup(ruleSet: ruleSet)
            results.append(result)
        }
        
        return results
    }
    
    /// Сохраняет конкретный набор правил в AppGroup
    private func saveRuleToAppGroup(ruleSet: RuleSetInfo) -> Bool {
        // 1. Загружаем JSON из bundle
        guard let jsonString = loadPreconvertedJSON(fileName: ruleSet.jsonFileName) else {
            print("❌ Не найден JSON файл: \(ruleSet.jsonFileName)")
            return false
        }
        
        // 2. Получаем путь в AppGroup
        guard let targetURL = getAppGroupFileURL(for: ruleSet.identifier) else {
            print("❌ Не удалось получить URL для AppGroup")
            return false
        }
        
        // 3. Записываем файл
        do {
            try jsonString.write(to: targetURL, atomically: true, encoding: .utf8)
            
            // Синхронизация файла
            let fileHandle = try FileHandle(forWritingTo: targetURL)
            try fileHandle.synchronize()
            try fileHandle.close()
            
            let fileSize = (try? FileManager.default.attributesOfItem(atPath: targetURL.path))?[.size] as? Int64 ?? 0
            print("✅ Загружено правил \(ruleSet.identifier) (\(fileSize) байт)")
            
            return true
        } catch {
            print("❌ Ошибка записи \(ruleSet.identifier): \(error)")
            return false
        }
    }
    
    /// Загружает готовый JSON из bundle приложения
    private func loadPreconvertedJSON(fileName: String) -> String? {
        guard let jsonPath = Bundle.main.path(forResource: fileName, ofType: "json") else {
            return nil
        }
        
        do {
            let jsonString = try String(contentsOfFile: jsonPath, encoding: .utf8)
            
            // Валидация
            guard !jsonString.isEmpty,
                  jsonString.contains("\"trigger\""),
                  jsonString.contains("\"action\"") else {
                print("⚠️ JSON файл \(fileName) невалидный")
                return nil
            }
            
            return jsonString
        } catch {
            print("❌ Ошибка чтения \(fileName): \(error)")
            return nil
        }
    }
    
    /// Получает URL файла в AppGroup
    private func getAppGroupFileURL(for identifier: String) -> URL? {
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            return nil
        }
        
        return groupURL.appendingPathComponent("\(identifier).json")
    }
    
    /// Создает пустое правило (заглушку) для отключения блокировщика
    private func createEmptyRule() -> String {
        let emptyRule: [[String: Any]] = [
            [
                "trigger": [
                    "url-filter": "^https?://never-existing-domain-for-adblocker-disabled\\.com/.*"
                ],
                "action": [
                    "type": "block"
                ]
            ]
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: emptyRule, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        
        return "[]"
    }
    
    /// Перезагружает все Safari расширения
    private func reloadAllExtensions() async {
        await withTaskGroup(of: Void.self) { group in
            for ruleSet in ruleSets {
                group.addTask {
                    await self.reloadExtension(bundleID: ruleSet.extensionBundleID)
                }
            }
        }
    }
    
    /// Перезагружает конкретное Safari расширение
    @MainActor
    private func reloadExtension(bundleID: String) async {
        let maxRetries = 3
        var attempts = 0
        
        while attempts < maxRetries {
            attempts += 1
            
            do {
                try await SFContentBlockerManager.reloadContentBlocker(withIdentifier: bundleID)
                print("✅ Перезагружено расширение: \(bundleID)")
                return
            } catch {
                if attempts == maxRetries {
                    print("❌ Не удалось перезагрузить расширение \(bundleID) после \(maxRetries) попыток")
                } else {
                    // Ждем перед следующей попыткой
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec
                }
            }
        }
    }
}

// MARK: - Factory

extension ContentBlockerAccepter {
    
    /// Создает инстанс с конфигурацией для Veilo
    static func makeDefault() -> ContentBlockerAccepter {
        let ruleSets: [RuleSetInfo] = [
            RuleSetInfo(
                identifier: Constants.RuleSets.adBlock.identifier,
                extensionBundleID: Constants.RuleSets.adBlock.extensionBundleID,
                jsonFileName: Constants.RuleSets.adBlock.outputFileName
            ),
            RuleSetInfo(
                identifier: Constants.RuleSets.privacy.identifier,
                extensionBundleID: Constants.RuleSets.privacy.extensionBundleID,
                jsonFileName: Constants.RuleSets.privacy.outputFileName
            ),
            RuleSetInfo(
                identifier: Constants.RuleSets.banners.identifier,
                extensionBundleID: Constants.RuleSets.banners.extensionBundleID,
                jsonFileName: Constants.RuleSets.banners.outputFileName
            ),
            RuleSetInfo(
                identifier: Constants.RuleSets.trackers.identifier,
                extensionBundleID: Constants.RuleSets.trackers.extensionBundleID,
                jsonFileName: Constants.RuleSets.trackers.outputFileName
            ),
            RuleSetInfo(
                identifier: Constants.RuleSets.advanced.identifier,
                extensionBundleID: Constants.RuleSets.advanced.extensionBundleID,
                jsonFileName: Constants.RuleSets.advanced.outputFileName
            ),
            RuleSetInfo(
                identifier: Constants.RuleSets.basic.identifier,
                extensionBundleID: Constants.RuleSets.basic.extensionBundleID,
                jsonFileName: Constants.RuleSets.basic.outputFileName
            )
        ]
        
        return ContentBlockerAccepter(
            appGroupID: Constants.adblockGroupId,
            ruleSets: ruleSets
        )
    }
}

