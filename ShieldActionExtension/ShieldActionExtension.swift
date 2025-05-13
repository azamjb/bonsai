//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Created by Azam Jawad on 2025-04-24.
//

import ManagedSettings
import Foundation
import UserNotifications

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        switch action {
        case .primaryButtonPressed:
            let sharedDefaults = UserDefaults(suiteName: "group.com.bonsai")
            sharedDefaults?.set("Head over to Bonsai to send a time extension request to your accountability partner", forKey: "shieldMessage")
            sendNotification()
            
            completionHandler(.defer)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            fatalError()
        }
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        switch action {
        case .primaryButtonPressed:
            let sharedDefaults = UserDefaults(suiteName: "group.com.bonsai")
            sharedDefaults?.set("Head over to Bonsai to send a time extension request to your accountability partner", forKey: "shieldMessage")
            sendNotification()
            
            completionHandler(.defer)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            fatalError()
        }
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        switch action {
        case .primaryButtonPressed:
            let sharedDefaults = UserDefaults(suiteName: "group.com.bonsai")
            sharedDefaults?.set("Head over to Bonsai to send a time extension request to your accountability partner", forKey: "shieldMessage")
            sendNotification()
            
            completionHandler(.defer)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            fatalError()
        }
    }
    
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Extend Boundary"
        content.body = "Click this to request extensions for boundaries."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending notification: \(error.localizedDescription)")
            }
        }
    }
}
