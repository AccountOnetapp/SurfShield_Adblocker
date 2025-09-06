//
//  UserDefaultsObserver.swift
//  SufrShield
//
//  Created by Артур Кулик on 06.09.2025.
//

import Foundation
import Combine

class UserDefaultsObserver: ObservableObject {
    static let shared = UserDefaultsObserver()
    private var cancellables = Set<AnyCancellable>()
    let userDefaultsService = UserDefaultsService.shared
    
    @Published var webViewBlockedStatistics: ResourceAnalysisData = .init()
    
    // Здесь пример одного наблюдаемого свойства — замените на ваши ключи и типы
    @Published var isAdbockerInabled: Bool {
        didSet {
            UserDefaultsService.shared.save(isAdbockerInabled, forKey: .adBlockerEnabled)
        }
    }
    
    // Инициализируем из UserDefaults
    init() {
        self.isAdbockerInabled = userDefaultsService.load(Bool.self, forKey: .adBlockRules) ?? false
        self.webViewBlockedStatistics = userDefaultsService.load(ResourceAnalysisData.self, forKey: .webViewBlockedStatistics) ?? .init()
    }
    
    func updateAdblockerState(_ isOn: Bool) {
        isAdbockerInabled = isOn
    }
    
    func updateWebViewBlockedStatistics(_ statistics: ResourceAnalysisData) {
        var newStatistics: ResourceAnalysisData = webViewBlockedStatistics
        newStatistics.blockedCount += statistics.blockedCount
        newStatistics.totalLoadedResources += statistics.totalLoadedResources
        newStatistics.totalPageResources += statistics.totalPageResources
        
        webViewBlockedStatistics = newStatistics
        userDefaultsService.save(newStatistics, forKey: .webViewBlockedStatistics)
    }
}
