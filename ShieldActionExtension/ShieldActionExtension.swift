//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Created by Azam Jawad on 2025-04-24.
//

import ManagedSettings
import Foundation

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
            completionHandler(.defer)
            
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            fatalError()
        }
    }
}
