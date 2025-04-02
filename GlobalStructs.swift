//
//  GlobalStructs.swift
//  bonsai
//
//  Created by Brayden O on 2025-03-30.
//

import Foundation
import ManagedSettings

public struct ScreenTimeActivityEvent: Codable, Identifiable, Hashable {
    public var id: UUID
    var givenName: String
    var appTokens: Set<ApplicationToken> = []
    var categoryTokens: Set<ActivityCategoryToken> = []
    var webDomainTokens: Set<WebDomainToken> = []
    var hours: Int
    var minutes: Int
    var weekdays: Set<Weekday>
    // An invisble limit is one that is set after they get an app unblocked from an accountability partner code. This bool tells us it isn't to be shown as a limit.
    var invisibleLimit: Bool
}

public enum GroupDisplayType: String {
    case limit = "LimitEvent+"
    case block = "BlockGroup+"
}

public enum Weekday: Int, CaseIterable, Codable {
    case sunday = 1, monday = 2, tuesday = 3, wednesday = 4, thursday = 5, friday = 6, saturday = 7
    
    static var today: Weekday {
        let today = Date()
        let calendar = Calendar.current
        return Weekday(rawValue: calendar.component(.weekday, from: today))!
    }
    
    var fullName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }

    var label: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }
}
