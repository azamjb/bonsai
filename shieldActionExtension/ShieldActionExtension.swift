//
//  ShieldActionExtension.swift
//  shieldActionExtension
//
//  Created by Brayden O on 2025-01-02.
//

import ManagedSettings

// Override the functions below to customize the shield actions used in various situations.
// The system provides a default response for any functions that your subclass doesn't override.
// Make sure that your class name matches the NSExtensionPrincipalClass in your Info.plist.
class ShieldActionExtension: ShieldActionDelegate {
    override init() {
        super.init()
        print("Shield aciton extension reached")
    }
    
    override func handle(action: ShieldAction, for application: ApplicationToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        switch action {
        case .primaryButtonPressed:
            print("primary")
            completionHandler(.close)
        case .secondaryButtonPressed:
            print("secondary")
            completionHandler(.defer)
        @unknown default:
            fatalError()
        }
    }
    
    override func handle(action: ShieldAction, for webDomain: WebDomainToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        switch action {
        case .primaryButtonPressed:
            print("primary")
            completionHandler(.close)
        case .secondaryButtonPressed:
            print("secondary")
            completionHandler(.defer)
        @unknown default:
            fatalError()
        }
    }
    
    override func handle(action: ShieldAction, for category: ActivityCategoryToken, completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Handle the action as needed.
        switch action {
        case .primaryButtonPressed:
            print("primary")
            completionHandler(.close)
        case .secondaryButtonPressed:
            print("secondary")
            completionHandler(.defer)
        @unknown default:
            fatalError()
        }
    }
}
