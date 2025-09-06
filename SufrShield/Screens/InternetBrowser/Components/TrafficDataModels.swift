//
//  TrafficDataModels.swift
//  SufrShield
//
//  Created by Артур Кулик on 03.09.2025.
//

import Foundation

// MARK: - Traffic Request Data
struct TrafficRequest {
    let url: String
    let method: String
    let headers: [String: String]
    let timestamp: Date
    let requestId: String
    
    init(url: String, method: String = "GET", headers: [String: String] = [:]) {
        self.url = url
        self.method = method
        self.headers = headers
        self.timestamp = Date()
        self.requestId = UUID().uuidString
    }
}

// MARK: - Traffic Response Data
struct TrafficResponse {
    let requestId: String
    let statusCode: Int
    let contentLength: Int64
    let contentType: String?
    let timestamp: Date
    let isBlocked: Bool
    
    init(requestId: String, statusCode: Int, contentLength: Int64, contentType: String? = nil, isBlocked: Bool = false) {
        self.requestId = requestId
        self.statusCode = statusCode
        self.contentLength = contentLength
        self.contentType = contentType
        self.timestamp = Date()
        self.isBlocked = isBlocked
    }
}

// MARK: - Resource Type
enum ResourceType: String, CaseIterable {
    case image = "image"
    case script = "script"
    case stylesheet = "stylesheet"
    case font = "font"
    case media = "media"
    case document = "document"
    case other = "other"
    
    init(from contentType: String?) {
        guard let contentType = contentType?.lowercased() else {
            self = .other
            return
        }
        
        if contentType.contains("image") {
            self = .image
        } else if contentType.contains("javascript") || contentType.contains("script") {
            self = .script
        } else if contentType.contains("css") || contentType.contains("stylesheet") {
            self = .stylesheet
        } else if contentType.contains("font") {
            self = .font
        } else if contentType.contains("video") || contentType.contains("audio") {
            self = .media
        } else if contentType.contains("html") || contentType.contains("document") {
            self = .document
        } else {
            self = .other
        }
    }
    
    init(from url: String) {
        let pathExtension = URL(string: url)?.pathExtension.lowercased() ?? ""
        
        switch pathExtension {
        case "jpg", "jpeg", "png", "gif", "webp", "svg", "ico", "bmp":
            self = .image
        case "js":
            self = .script
        case "css":
            self = .stylesheet
        case "woff", "woff2", "ttf", "otf", "eot":
            self = .font
        case "mp4", "mp3", "avi", "mov", "wav", "webm", "ogg":
            self = .media
        case "html", "htm":
            self = .document
        default:
            self = .other
        }
    }
}

// MARK: - Blocked Resource
struct BlockedResource {
    let url: String
    let size: Int64
    let type: ResourceType
    let timestamp: Date
    let reason: BlockReason
    
    enum BlockReason: String, CaseIterable {
        case adDomain = "ad_domain"
        case adPattern = "ad_pattern"
        case tracker = "tracker"
        case analytics = "analytics"
        case social = "social"
        case other = "other"
    }
}

// MARK: - Traffic Statistics
struct TrafficStatistics {
    var totalBlockedBytes: Int64 = 0
    var totalAllowedBytes: Int64 = 0
    var blockedRequestsCount: Int = 0
    var allowedRequestsCount: Int = 0
    var blockedResources: [BlockedResource] = []
    var sessionStartTime: Date = Date()
    
    // Computed properties
    var totalSavedBytes: Int64 {
        return totalBlockedBytes
    }
    
    var totalRequestsCount: Int {
        return blockedRequestsCount + allowedRequestsCount
    }
    
    var savingsPercentage: Double {
        let totalBytes = totalBlockedBytes + totalAllowedBytes
        guard totalBytes > 0 else { return 0.0 }
        return Double(totalBlockedBytes) / Double(totalBytes) * 100.0
    }
    
    var sessionDuration: TimeInterval {
        return Date().timeIntervalSince(sessionStartTime)
    }
    
    // Formatted values
    var formattedSavedBytes: String {
        return formatBytes(totalSavedBytes)
    }
    
    var formattedAllowedBytes: String {
        return formatBytes(totalAllowedBytes)
    }
    
    var formattedSavingsPercentage: String {
        return String(format: "%.1f%%", savingsPercentage)
    }
    
    var formattedSessionDuration: String {
        let duration = sessionDuration
        if duration < 60 {
            return String(format: "%.0f сек", duration)
        } else if duration < 3600 {
            return String(format: "%.1f мин", duration / 60)
        } else {
            return String(format: "%.1f ч", duration / 3600)
        }
    }
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    // Statistics by resource type
    func getBlockedBytesByType() -> [ResourceType: Int64] {
        var result: [ResourceType: Int64] = [:]
        for resource in blockedResources {
            result[resource.type, default: 0] += resource.size
        }
        return result
    }
    
    func getBlockedCountByType() -> [ResourceType: Int] {
        var result: [ResourceType: Int] = [:]
        for resource in blockedResources {
            result[resource.type, default: 0] += 1
        }
        return result
    }
}
