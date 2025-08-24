//
//  ContentBlockerRequestHandler.swift
//  adblocker
//
//  Created by Артур Кулик on 24.08.2025.
//

import UIKit
import MobileCoreServices

class ContentBlockerRequestHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        // Сначала пытаемся загрузить правила из памяти устройства
//        if let deviceRules = RuleConverter.loadRulesFromDevice(filename: "converted_blockerList") {
//            // Используем правила из памяти устройства
//            let attachment = NSItemProvider(item: deviceRules as NSSecureCoding?, typeIdentifier: String(kUTTypeJSON))
//            
//            let item = NSExtensionItem()
//            item.attachments = [attachment]
//            
//            context.completeRequest(returningItems: [item], completionHandler: nil)
//            print("✅ Используются правила из памяти устройства")
//        } else {
//            // Fallback на встроенный файл
//            let attachment = NSItemProvider(contentsOf: Bundle.main.url(forResource: "blockerList", withExtension: "json"))!
//            
//            let item = NSExtensionItem()
//            item.attachments = [attachment]
//            
//            context.completeRequest(returningItems: [item], completionHandler: nil)
//            print("⚠️ Используется встроенный файл правил")
//        }
    }
}
