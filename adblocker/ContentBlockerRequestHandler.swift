//
//  ContentBlockerRequestHandler.swift
//  adblocker
//
//  Created by Артур Кулик on 24.08.2025.
//

import UIKit
import MobileCoreServices
import Foundation

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        // Пытаемся загрузить правила из App Group
        let rulesURL = loadRulesFromAppGroup()
        
        let attachment: NSItemProvider
        
        if let rulesURL = rulesURL {
            attachment = NSItemProvider(contentsOf: rulesURL)!
        } else {
            // Fallback к файлу из bundle
            attachment = NSItemProvider(contentsOf: Bundle.main.url(forResource: "blockerList", withExtension: "json"))!
        }
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
    
    private func loadRulesFromAppGroup() -> URL? {
        let fileManager = FileManager.default
        let groupID = Constants.adblockGroupId
        
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            return nil
        }
        
        let rulesFileURL = groupURL.appendingPathComponent("new_rules.json")
        
        // Проверяем только существование файла
        guard fileManager.fileExists(atPath: rulesFileURL.path) else {
            return nil
        }
        
        return rulesFileURL
    }
}
