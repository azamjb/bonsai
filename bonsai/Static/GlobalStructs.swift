//
//  GlobalStructs.swift
//  bonsai
//
//  Created by Brayden O on 2025-03-30.
//

import Foundation
import ManagedSettings


public enum TokenType: String, CaseIterable, Codable {
    case app = "appToken", category = "categoryToken", webDomain = "webDomainToken"
}

public enum Weekday: Int, CaseIterable, Codable {
    case monday = 1, tuesday = 2, wednesday = 3, thursday = 4, friday = 5, saturday = 6, sunday = 7
    
    static var today: Weekday {
        let today = Date()
        let calendar = Calendar.current
        let calendarWeekday = calendar.component(.weekday, from: today)
        
        switch calendarWeekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday 
        }
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
