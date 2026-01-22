//
//  Utils.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//

import Foundation
import UserNotifications

func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

func areDatesSameDay(date1: Date, date2: Date) -> Bool {
    Calendar.current.isDate(date1, inSameDayAs: date2)
}

func getDateInWeekStartingFromThisMonday(weekday: Weekday) -> Date? {
    let today = Date()
    let calendar = Calendar.current
    
    let startOfToday = calendar.startOfDay(for: today)
    
    let recentMonday = startOfToday.previous(.monday, considerToday: true)
    
    if weekday == .monday && calendar.isDate(startOfToday, inSameDayAs: recentMonday) {
        return recentMonday
    }
    
    let targetWeekDay = recentMonday.next(weekday)
    
    if targetWeekDay <= startOfToday {
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
    catch _{
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

public func sendNotification(title: String, body: String) {
    let content = UNMutableNotificationContent()
    content.title = title
    content.body = body
    content.sound = .default
    
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    
    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("Error sending notification: \(error.localizedDescription)")
        }
    }
}
