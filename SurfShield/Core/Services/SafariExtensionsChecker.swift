//
//  SafariExtensionsChecker.swift
//  SurfShield
//
//  Created by Артур Кулик on 05.10.2025.
//

import Foundation
import SafariServices

class SafariExtensionsChecker {
    private let extensionsBundles: [String] = Constants.BlockExtenesionBundleIds.all
    
    func isExtensionEnabled() async -> Bool {
        let results = await withTaskGroup(of: Bool.self) { group in
            for id in extensionsBundles {
                group.addTask {
                    await self.isExtensionEnabled(id)
                }
            }
            
            var enabledCount = 0
            for await isEnabled in group {
                if isEnabled {
                    enabledCount += 1
                }
            }
            return enabledCount == extensionsBundles.count
        }
        
        return results
    }

    @MainActor
    private func isExtensionEnabled(_ id: String) async -> Bool {
        await withCheckedContinuation { continuation in
            SFContentBlockerManager.getStateOfContentBlocker(withIdentifier: id) { state, error in
                // Проверяем наличие расширения и его состояние
                let isEnabled = state?.isEnabled == true
                continuation.resume(returning: isEnabled)
            }
        }
    }
}
