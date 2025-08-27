//
//  Entities.swift
//  bonsai
//
//  Created by Brayden O on 2025-08-10.
//  Copyright © 2025 Bonsai Software Incorporated. All rights reserved.
//

import Foundation
import ManagedSettings
import GRDB

// MARK: - Boundary
public struct Boundary: Codable, Identifiable, Hashable, FetchableRecord, PersistableRecord {
    public var id: UUID
    var givenName: String
    var appTokens: Set<ApplicationToken> = []
    var categoryTokens: Set<ActivityCategoryToken> = []
    var webDomainTokens: Set<WebDomainToken> = []
    var hours: Int
    var minutes: Int
    var weekdays: Set<Weekday>
    var isBlocked: Bool = false
    // An invisble boundary is one that is set after they get an app unblocked from an accountability partner code. This bool tells us it isn't to be shown as a limit.
    var invisibleBoundary: Bool
    
    public init(
        id: UUID,
        givenName: String,
        appTokens: Set<ApplicationToken> = [],
        categoryTokens: Set<ActivityCategoryToken> = [],
        webDomainTokens: Set<WebDomainToken> = [],
        hours: Int,
        minutes: Int,
        weekdays: Set<Weekday>,
        isBlocked: Bool = false,
        invisibleBoundary: Bool
    ) {
        self.id = id
        self.givenName = givenName
        self.appTokens = appTokens
        self.categoryTokens = categoryTokens
        self.webDomainTokens = webDomainTokens
        self.hours = hours
        self.minutes = minutes
        self.weekdays = weekdays
        self.isBlocked = isBlocked
        self.invisibleBoundary = invisibleBoundary
    }
    
    // GRDB FetchableRecord conformance
    public init(row: Row) {
        id = UUID(uuidString: row["id"]) ?? UUID()
        givenName = row["givenName"]
        hours = row["hours"]
        minutes = row["minutes"]
        isBlocked = row["isBlocked"]
        invisibleBoundary = row["invisibleBoundary"]
        
        if let jsonString: String = row["appTokens"] {
            appTokens = Set(try! JSONDecoder().decode([ApplicationToken].self, from: jsonString.data(using: .utf8)!))
        } else {
            appTokens = []
        }
        
        if let jsonString: String = row["categoryTokens"] {
            categoryTokens = Set(try! JSONDecoder().decode([ActivityCategoryToken].self, from: jsonString.data(using: .utf8)!))
        } else {
            categoryTokens = []
        }
        
        if let jsonString: String = row["webDomainTokens"] {
            webDomainTokens = Set(try! JSONDecoder().decode([WebDomainToken].self, from: jsonString.data(using: .utf8)!))
        } else {
            webDomainTokens = []
        }
        
        if let jsonString: String = row["weekdays"] {
            weekdays = Set(try! JSONDecoder().decode([Weekday].self, from: jsonString.data(using: .utf8)!))
        } else {
            weekdays = []
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id, givenName, appTokens, categoryTokens, webDomainTokens, hours, minutes, weekdays, isBlocked, invisibleBoundary
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode UUID as string
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(givenName, forKey: .givenName)
        try container.encode(hours, forKey: .hours)
        try container.encode(minutes, forKey: .minutes)
        try container.encode(isBlocked, forKey: .isBlocked)
        try container.encode(invisibleBoundary, forKey: .invisibleBoundary)
        
        // Encode sets as JSON strings
        let appTokensData = try JSONEncoder().encode(Array(appTokens))
        try container.encode(String(data: appTokensData, encoding: .utf8), forKey: .appTokens)
        
        let categoryTokensData = try JSONEncoder().encode(Array(categoryTokens))
        try container.encode(String(data: categoryTokensData, encoding: .utf8), forKey: .categoryTokens)
        
        let webDomainTokensData = try JSONEncoder().encode(Array(webDomainTokens))
        try container.encode(String(data: webDomainTokensData, encoding: .utf8), forKey: .webDomainTokens)
        
        let weekdaysData = try JSONEncoder().encode(Array(weekdays))
        try container.encode(String(data: weekdaysData, encoding: .utf8), forKey: .weekdays)
    }
    
    // Also add the corresponding decode method to be complete
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Handle UUID - could be string or UUID
        if let uuidString = try? container.decode(String.self, forKey: .id) {
            id = UUID(uuidString: uuidString) ?? UUID()
        } else {
            id = try container.decode(UUID.self, forKey: .id)
        }
        
        givenName = try container.decode(String.self, forKey: .givenName)
        hours = try container.decode(Int.self, forKey: .hours)
        minutes = try container.decode(Int.self, forKey: .minutes)
        isBlocked = try container.decode(Bool.self, forKey: .isBlocked)
        invisibleBoundary = try container.decode(Bool.self, forKey: .invisibleBoundary)
        
        // Decode JSON strings to sets
        if let appTokensString = try container.decodeIfPresent(String.self, forKey: .appTokens),
           let data = appTokensString.data(using: .utf8) {
            appTokens = Set(try JSONDecoder().decode([ApplicationToken].self, from: data))
        } else {
            appTokens = []
        }
        
        if let categoryTokensString = try container.decodeIfPresent(String.self, forKey: .categoryTokens),
           let data = categoryTokensString.data(using: .utf8) {
            categoryTokens = Set(try JSONDecoder().decode([ActivityCategoryToken].self, from: data))
        } else {
            categoryTokens = []
        }
        
        if let webDomainTokensString = try container.decodeIfPresent(String.self, forKey: .webDomainTokens),
           let data = webDomainTokensString.data(using: .utf8) {
            webDomainTokens = Set(try JSONDecoder().decode([WebDomainToken].self, from: data))
        } else {
            webDomainTokens = []
        }
        
        if let weekdaysString = try container.decodeIfPresent(String.self, forKey: .weekdays),
           let data = weekdaysString.data(using: .utf8) {
            weekdays = Set(try JSONDecoder().decode([Weekday].self, from: data))
        } else {
            weekdays = []
        }
    }
}

// MARK: - TokenTransaction
public struct TokenTransaction: Codable, FetchableRecord, PersistableRecord, Identifiable {
    public var id: UUID
    var userId: String
    var transactionId: String?
    var timestamp: Date
    var netTokenChange: Int
    var balanceAfterChange: Int
    var type: TokenTransactionType
}

enum TokenTransactionType: String, Codable {
    case purchase = "PURCHASE"
    case spend = "SPEND"
    case grant = "GRANTS" // this is likely for subscriptions to be able to gift from the app without purchase process
}

enum TokenResponseCode {
    case success
    case insufficientTokenBalance
    case overrideLimitReached
    case serverError
}

// MARK: - DailyBoundaryExtension
public struct DailyBoundaryExtension: Codable, Hashable, FetchableRecord, PersistableRecord {
    var boundaryId: UUID
    var extendedDateTimeUtc: Date
}

// MARK: - SentExtensionCode
public struct SentExtensionCode: Identifiable, Codable, Hashable, FetchableRecord, PersistableRecord {
    public var id: UUID
    var boundaryId: UUID
    var code: String
    var sentDateTimeUtc: Date
    var isCodeValid: Bool = true
}
