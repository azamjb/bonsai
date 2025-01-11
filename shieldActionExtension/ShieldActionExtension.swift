//
//  ShieldActionExtension.swift
//  shieldActionExtension
//
//  Created by Brayden O on 2025-01-02.
//

import ManagedSettings
import Foundation
import UIKit

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            openBonsai(application: application)
            completionHandler(.defer)
        @unknown default:
            fatalError()
        }
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            openBonsai(webDomain: webDomain)
            completionHandler(.defer)
        @unknown default:
            fatalError()
        }
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        switch action {
        case .primaryButtonPressed:
            completionHandler(.close)
        case .secondaryButtonPressed:
            openBonsai(category: category)
            completionHandler(.defer)
        @unknown default:
            fatalError()
        }
    }
    
    private func openBonsai(application: ApplicationToken) {
        NSLog("Extend for app: \(application)")
        
        let content = UNMutableNotificationContent()
        content.title = "Extend time"
        content.body = "Extend time for this app"
        content.sound = .default
        
        let identifier = "extension-\(UUID().uuidString)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                NSLog("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func openBonsai(category: ActivityCategoryToken) {
        NSLog("Extend for app in category: \(category)")
    }

    private func openBonsai(webDomain: WebDomainToken) {
        NSLog("Extend for app in web domain: \(webDomain)")
    }
}
