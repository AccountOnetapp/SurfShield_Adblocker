//
//  ContentBlockerRepository.swift
//  SurfShield
//
//  Created by Артур Кулик on 09.10.2025.
//

import Foundation

class ContentBlockerRepository {
    private let contentBlockerAccepter: ContentBlockerAccepter
    
    init() {
        self.contentBlockerAccepter = ContentBlockerAccepter.makeDefault()
    }
    
    func applyBlocker(_ isOn: Bool) async {
        if isOn {
            await contentBlockerAccepter.applyBlockingRules()
        } else {
            await contentBlockerAccepter.disableBlockingRules()
        }
    }
}
