//
//  ContentBlockerRepository.swift
//  SurfShield
//
//  Created by Артур Кулик on 09.10.2025.
//

import Foundation

class ContentBlockerRepository {
    let contentBlockerService: ContentBlockerServiceNew
    
    init(blockerService: ContentBlockerServiceNew) {
        self.contentBlockerService = blockerService
    }
    
    func applyBlocker(_ isOn: Bool) async {
//        await contentBlockerService.applyBlockingState(isOn)
        await contentBlockerService.enableBlocker(isOn: isOn)
    }
}
