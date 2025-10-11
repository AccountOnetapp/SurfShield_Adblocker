//
//  ContentBlockerRepository.swift
//  SurfShield
//
//  Created by Артур Кулик on 09.10.2025.
//

import Foundation

class ContentBlockerRepository {
    let contentBlockerService: ContentBlockerService
    
    init(blockerService: ContentBlockerService) {
        self.contentBlockerService = blockerService
    }
    
    func applyBlocker(_ isOn: Bool) async {
        await contentBlockerService.applyBlockingState(isOn)
    }
}
