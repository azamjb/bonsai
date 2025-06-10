//
//  GlobalStructs.swift
//  bonsai
//
//  Created by Brayden O on 2025-03-30.
//

import Foundation
import ManagedSettings

public struct Boundary: Codable, Identifiable, Hashable {
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
}

public enum Weekday: Int, CaseIterable, Codable {
    case monday = 1, tuesday = 2, wednesday = 3, thursday = 4, friday = 5, saturday = 6, sunday = 7
    
    static var today: Weekday {
        let today = Date()
        let calendar = Calendar.current
        return Weekday(rawValue: calendar.component(.weekday, from: today) - 1)!
    }
    
    var fullName: String {
        switch self {
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        case .sunday: return "Sunday"
        }
    }

    var label: String {
        switch self {
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        case .sunday: return "S"
        }
    }
}

public struct DailyBoundaryExtensionsModel: Codable, Hashable {
    var boundaryId: UUID
    var extendedDateTimeUtc: Date
}

public struct SentExtensionCodeModel: Codable, Hashable {
    var boundaryId: UUID
    var code: String
    var sentDateTimeUtc: Date
    var isCodeValid: Bool = true
}

public enum TokenType: String, CaseIterable, Codable {
    case app = "appToken", category = "categoryToken", webDomain = "webDomainToken"
}
