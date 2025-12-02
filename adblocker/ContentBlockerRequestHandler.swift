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
        let rulesURL = getAdBlockRulesURL()
        let attachment = NSItemProvider(contentsOf: rulesURL)!
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
    
    /// Получает URL файла правил adBlock с fallback к bundle
    private func getAdBlockRulesURL() -> URL? {
        let fileManager = FileManager.default
        let appGroupID = Constants.adblockGroupId
        
        // 1. Сначала проверяем файл в AppGroup
        if let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            let appGroupURL = groupURL.appendingPathComponent("adBlock.json")
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
