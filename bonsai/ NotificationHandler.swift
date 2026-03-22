//
//   NotificationHandler.swift
//  bonsai
//
//  Created by Brayden O on 2025-05-07.
//

import SwiftUI
import UserNotifications
import ManagedSettings

class NotificationHandler: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    @Published var showExtensionRequest: Bool = false
    
    static let shared = NotificationHandler()
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification authorization granted")
            } else if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            }
        }
    }
    
    // Called when a notification is received while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Received notification in foreground: \(userInfo)")
        
        // Show the notification
        completionHandler([.banner, .sound])
    }
    
    // Called when the user taps a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("User tapped notification: \(userInfo)")
        completionHandler()
    }

    // Schedules (or reschedules) the 9pm daily summary notification.
    // Called each time the app becomes active so the content reflects the current day.
    func scheduleDailySummaryNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [DAILY_SUMMARY_NOTIFICATION_ID])

        let sharedDefaults = UserDefaults(suiteName: BONSAI_GROUP_NAME)

        // Count extensions granted today from shared UserDefaults
        var todayExtensionCount = 0
        if let data = sharedDefaults?.data(forKey: "dailyBoundaryExtensions"),
           let extensions = try? JSONDecoder().decode([DailySummaryExtensionEntry].self, from: data) {
            let calendar = Calendar.current
            todayExtensionCount = extensions.filter { calendar.isDateInToday($0.extendedDateTimeUtc) }.count
        }

        let content = UNMutableNotificationContent()
        content.title = "Daily Summary"
        if todayExtensionCount == 0 {
            content.body = "No extensions granted today. Your boundaries held strong."
        } else {
            let word = todayExtensionCount == 1 ? "extension" : "extensions"
            content.body = "\(todayExtensionCount) \(word) granted today. Tomorrow is a fresh start."
        }
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 21
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: DAILY_SUMMARY_NOTIFICATION_ID, content: content, trigger: trigger)

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule daily summary notification: \(error)")
            }
        }
    }
}

// Lightweight decodable matching the DailyBoundaryExtension JSON stored in shared UserDefaults
private struct DailySummaryExtensionEntry: Decodable {
    let extendedDateTimeUtc: Date
}
