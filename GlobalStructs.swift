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

// The values are the Ids of the Boundaries that they've extended
public struct DailyBoundaryExtensionsModel: Codable, Hashable {
    var monday: [UUID] = []
    var tuesday: [UUID] = []
    var wednesday: [UUID] = []
    var thursday: [UUID] = []
    var friday: [UUID] = []
    var saturday: [UUID] = []
    var sunday: [UUID] = []
    
    public mutating func setByWeekday(weekday: Weekday, newValues: [UUID]) {
        switch weekday {
        case .monday: monday = newValues
        case .tuesday: tuesday = newValues
        case .wednesday: wednesday = newValues
        case .thursday: thursday = newValues
        case .friday: friday = newValues
        case .saturday: saturday = newValues
        case .sunday: sunday = newValues
        }
    }
    
    public mutating func appendByWeekday(weekday: Weekday, valueToAppend: UUID) {
        switch weekday {
        case .monday: monday.append(valueToAppend)
        case .tuesday: tuesday.append(valueToAppend)
        case .wednesday: wednesday.append(valueToAppend)
        case .thursday: thursday.append(valueToAppend)
        case .friday: friday.append(valueToAppend)
        case .saturday: saturday.append(valueToAppend)
        case .sunday: sunday.append(valueToAppend)
        }
    }
}

let REMAINING_BOUNDARY_EXTENSIONS_STRING = "remainingBoundaryExtensions"
let DAILY_BOUNDARY_EXTENSIONS_STRING = "dailyBoundaryExtensions"
let LAST_SUCCESSFUL_UNSHIELD_STRING = "lastSuccessfulUnshield"
let BOUNDARIES_STRING = "boundaries"
