//
//  Utils.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//

import Foundation

func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

func isValidPhoneNumber() {
    
}

func areDatesSameDay(date1: Date, date2: Date) -> Bool {
    let calendar = Calendar.current
    
    let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
    let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
    
    return components1.year == components2.year &&
           components1.month == components2.month &&
           components1.day == components2.day
}

func getDateInWeekStartingFromThisMonday(weekday: Weekday) -> Date? {
    let today = Date()
    
    let recentMonday = today.previous(.monday, considerToday: true)
    let targetWeekDay = recentMonday.next(weekday)
    
    if targetWeekDay <= today {
        return targetWeekDay
    }
    
    return nil
}

//Used to expose generic
func DeepCopy<T:Codable>(_ object:T) -> T?{
   do{
       let json = try JSONEncoder().encode(object)
       return try JSONDecoder().decode(T.self, from: json)
   }
   catch let error{
       return nil
   }
}

public func mediumDateFormat(date: Date) -> String {
    let fmtr: DateFormatter = DateFormatter()
    fmtr.dateFormat = "MMM d, yyyy"
    fmtr.timeZone = TimeZone.current

    return fmtr.string(from: date).filter({ char in char != "," })
}

public func timeInUserTimeZone12hour(date: Date) -> String {
    let fmtr = DateFormatter()
    fmtr.dateFormat = "h:mm a"
    fmtr.timeZone = TimeZone.current
    
    return fmtr.string(from: date)
}

public func mediumDateTimeFormat(date: Date) -> String {
    let fmtr = DateFormatter()
    fmtr.dateFormat = "MMM d, yyyy h:mm a"
    fmtr.timeZone = TimeZone.current
    
    return fmtr.string(from: date)
}
