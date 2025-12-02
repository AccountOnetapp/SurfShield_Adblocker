//
//  ContentBlockerRequestHandler.swift
//  basic
//
//  Created by Артур Кулик on 03.09.2025.
//

import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let rulesURL = getBasicRulesURL()
        let attachment = NSItemProvider(contentsOf: rulesURL)!
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
    
    /// Получает URL файла правил basic с fallback к bundle
    private func getBasicRulesURL() -> URL? {
        let fileManager = FileManager.default
        let appGroupID = Constants.adblockGroupId
        
        // 1. Сначала проверяем файл в AppGroup
        if let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            let appGroupURL = groupURL.appendingPathComponent("basic.json")
            if fileManager.fileExists(atPath: appGroupURL.path) {
                return appGroupURL
            }
        }
        
        // 2. Fallback к blockerList.json в bundle
        if let bundleURL = Bundle.main.url(forResource: "blockerList", withExtension: "json") {
            return bundleURL
        }
        
        return nil
    }
}
