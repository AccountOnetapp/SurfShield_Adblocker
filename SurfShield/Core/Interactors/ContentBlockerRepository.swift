//
//  ContentBlockerRepository.swift
//  SurfShield
//
//  Created by Артур Кулик on 09.10.2025.
//

import Foundation

class ContentBlockerRepository {
    let contentBlockerService: ContentBlockerService
    let contentBlockerAccepter = ContentBlockerAccepter(appGroupID: Constants.adblockGroupId, rulesFileName: "adblock_rules", extensionBundleIDs: [Constants.BlockExtenesionBundleIds.adblocker.rawValue])
    
    init(blockerService: ContentBlockerService) {
        self.contentBlockerService = blockerService
    }
    
    func applyBlocker(_ isOn: Bool) async {
        if isOn {
            await contentBlockerAccepter.applyBlockingRules()
        } else {
            await contentBlockerAccepter.disableBlockingRules()
        }
//        await contentBlockerService.applyBlockingState(isOn)
    }
}
