//
//  ContentBlockerAccepter.swift
//  SurfShield
//
//  Created by Claude on 01.12.2025.
//

import Foundation
import SafariServices

/// Сервис для быстрого применения готовых JSON правил блокировки
/// Загружает adblock_rules.json из корня проекта и применяет к расширениям
final class ContentBlockerAccepter {
    
    // MARK: - Properties
    
    private let appGroupID: String
    private let rulesFileName: String
    private let extensionBundleIDs: [String]
    private var currentTask: Task<Bool, Never>?
    
    // Имя файла правил для adblocker расширения
    private static let adBlockRulesType = "adBlock"
    
    // MARK: - Initialization
    
    init(appGroupID: String, rulesFileName: String, extensionBundleIDs: [String]) {
        self.appGroupID = appGroupID
        self.rulesFileName = rulesFileName
        self.extensionBundleIDs = extensionBundleIDs
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
            
            // 1. Загружаем и сохраняем правила из adblock_rules.json
            guard self.saveRulesToAppGroup() else {
                print("❌ Не удалось сохранить правила")
                return false
            }
            
            // Проверяем отмену после сохранения
            guard !Task.isCancelled else {
                print("⚠️ Операция отменена после сохранения")
                return false
            }
            
            print("✅ Правила сохранены в AppGroup")
            
            // 2. Перезагружаем Safari расширения (асинхронно)
            await self.reloadAllExtensions()
            
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
            
            // Записываем пустые правила (заглушки) для adblocker расширения
            let emptyRule = self.createEmptyRule()
            
            guard !Task.isCancelled else {
                print("⚠️ Операция отменена")
                return false
            }
            
            if let fileURL = self.getAppGroupFileURL(forRulesType: Self.adBlockRulesType) {
                do {
                    try emptyRule.write(to: fileURL, atomically: true, encoding: .utf8)
                    print("✅ Пустые правила сохранены для \(Self.adBlockRulesType).json")
                } catch {
                    print("❌ Ошибка отключения \(Self.adBlockRulesType): \(error)")
                    return false
                }
            } else {
                print("❌ Не удалось получить URL для \(Self.adBlockRulesType)")
                return false
            }
            
            // Перезагружаем расширения
            await self.reloadAllExtensions()
            
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
    
    /// Сохраняет правила из adblock_rules.json в AppGroup для adblocker расширения
    private func saveRulesToAppGroup() -> Bool {
        // 1. Загружаем JSON из bundle
        guard let jsonString = loadAdBlockRulesJSON() else {
            print("❌ Не найден файл: \(rulesFileName)")
            return false
        }
        
        print("✅ Загружен файл \(rulesFileName) (\(jsonString.count) символов)")
        
        // 2. Сохраняем правила для adblocker расширения
        guard let targetURL = getAppGroupFileURL(forRulesType: Self.adBlockRulesType) else {
            print("❌ Не удалось получить URL для \(Self.adBlockRulesType)")
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
            print("✅ Сохранено для \(Self.adBlockRulesType).json (\(fileSize) байт)")
            return true
        } catch {
            print("❌ Ошибка записи для \(Self.adBlockRulesType): \(error)")
            return false
        }
    }
    
    /// Загружает JSON правила из adblock_rules.json в корне проекта
    private func loadAdBlockRulesJSON() -> String? {
        // Пробуем загрузить из bundle (без расширения, т.к. указываем его явно)
        let fileNameWithoutExtension = rulesFileName.replacingOccurrences(of: ".json", with: "")
        
        guard let jsonPath = Bundle.main.path(forResource: fileNameWithoutExtension, ofType: "json") else {
            print("❌ Не найден файл \(rulesFileName) в bundle")
            return nil
        }
        
        do {
            let jsonString = try String(contentsOfFile: jsonPath, encoding: .utf8)
            
            // Базовая валидация JSON
            guard !jsonString.isEmpty,
                  jsonString.contains("\"trigger\""),
                  jsonString.contains("\"action\"") else {
                print("⚠️ JSON файл \(rulesFileName) невалидный или пустой")
                return nil
            }
            
            return jsonString
        } catch {
            print("❌ Ошибка чтения \(rulesFileName): \(error)")
            return nil
        }
    }
    
    /// Получает URL файла в AppGroup для конкретного типа правил
    /// - Parameter rulesType: Имя типа правил (например, "adBlock", "privacy")
    private func getAppGroupFileURL(forRulesType rulesType: String) -> URL? {
        guard let groupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupID
        ) else {
            return nil
        }
        
        return groupURL.appendingPathComponent("\(rulesType).json")
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
    
    /// Перезагружает adblocker расширение
    private func reloadAllExtensions() async {
        await self.reloadExtension(bundleID: Constants.BlockExtenesionBundleIds.adblocker.rawValue)
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
    
    /// Создает инстанс с конфигурацией для SurfShield
    /// Загружает adblock_rules.json и применяет к adblocker расширению
    static func makeDefault() -> ContentBlockerAccepter {
        return ContentBlockerAccepter(
            appGroupID: Constants.adblockGroupId,
            rulesFileName: "adblock_rules.json",
            extensionBundleIDs: [Constants.BlockExtenesionBundleIds.adblocker.rawValue]
        )
    }
}

