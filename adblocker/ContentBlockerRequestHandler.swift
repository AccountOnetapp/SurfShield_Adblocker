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
        let attachment = NSItemProvider(contentsOf: Bundle.main.url(forResource: "blockerList", withExtension: "json"))!
//        let filePath = RulesConverter.getExtensionFileURL(forType: .adware)!
//        let attachment = NSItemProvider(contentsOf: filePath)!
        
        let item = NSExtensionItem()
        item.attachments = [attachment]
        
        context.completeRequest(returningItems: [item], completionHandler: nil)
    }
    
//    func beginRequest(with context: NSExtensionContext) {
//        guard let filePath = ContentBlocker.getExtensionFileURL(forType: .adware) else { return }
//        let attachment = NSItemProvider(contentsOf: filePath)!
//
//        let item = NSExtensionItem()
//        item.attachments = [attachment]
//        context.completeRequest(returningItems: [item], completionHandler: nil)
//    }
    
}
