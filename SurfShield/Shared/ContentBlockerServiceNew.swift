//
//  ContentBlockerServiceNew.swift
//  SurfShield
//
//  Created by Артур Кулик on 30.11.2025.
//

import Foundation

class ContentBlockerServiceNew {
    private let groupID: String = Constants.adblockGroupId
    private let extensionsBundles: String = Constants.BlockExtenesionBundleIds.adblocker.rawValue
    
    var fileName: String {
        return "domains"
    }
    
    var filePath: String {
        guard let path = Bundle.main.path(forResource: fileName, ofType: "txt") else { return "" }
        return path
    }
    
    
    
    func enableBlocker(isOn: Bool) async {
        isOn ? enable() : disable()
    }
    
    func enable() {
        guard !filePath.isEmpty else {
            print("❌ Файл domains.txt не найден")
            return
        }
        
        let rulesString = try! String(contentsOfFile: filePath, encoding: .utf8)
        let lines = rulesString.components(separatedBy: .newlines).filter { !$0.isEmpty }
        
        var rules = [[String:Any]]()
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedLine.isEmpty else { continue }
            
            let rule = [
                "trigger" : [
                    "url-filter": "^https?:/+([^/:]+\\.)?\(trimmedLine)[:/]",
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
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: rules, options: [.prettyPrinted]),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            print("❌ Ошибка конвертации правил в JSON")
            return
        }
        
        // Используем getFilePath для получения правильного пути к файлу
        guard let fileURL = getFilePath(groupID: groupID) else {
            print("❌ Не удалось получить путь к файлу adBlock.json")
            return
        }
        
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
                print("✅ Правила успешно сохранены: \(fileURL.path) (размер: \(fileSize) байт)")
            } else {
                print("❌ Файл не найден после записи: \(fileURL.path)")
            }
        } catch {
            print("❌ Ошибка записи правил: \(error.localizedDescription)")
        }
    }
    
    func saveRules() {
        guard let filePath = getFilePath(groupID: groupID) else { return }
        
        let fileManager = FileManager.default
        
    }
    
    func disable() {
        
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
