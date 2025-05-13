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
}
