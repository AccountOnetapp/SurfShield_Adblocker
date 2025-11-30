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
        let rulesString = try! String(String(contentsOfFile: filePath, encoding: .utf8))
        let lines = rulesString.components(separatedBy: .newlines)
//        let chunkedRules = lines.chunked(by: 140000)
        var resultArray: [String] = []
        var rules = [[String:Any]]()
        
        for line in lines {
            let rule = [
                "trigger" : [
                    "url-filter": "^https?:/+([^/:]+\\.)?\(line)[:/]",
                    "load-type": [
                        "third-party",
                        "first-party"
                    ]
                ],
                "action": [
                    "type": "block",
                ]
            ]
            
            rules.append(rule)
        }
        
        let jsonData = try? JSONSerialization.data(withJSONObject: rules, options: [.prettyPrinted])
        let jsonString = String(data: jsonData!, encoding: .utf8)!
        
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            print("❌ Не удалось получить доступ к App Group для кэша")
            return
        }
        
        do {
            try jsonData?.write(to: groupURL)
        } catch {
            print("не получилось сохранить в кэш")
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
        let fileURL = groupURL.appendingPathComponent("\("adBlock").json")
        return fileURL
    }
    
}
