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
        print("Extend for app: \(application)")
        
        if let url = URL(string: "bonsaiapp://?application=\(application)") {
            print("gud url")
            let context = NSExtensionContext()
            
            context.open(url)
        }
    }
    
    private func openBonsai(category: ActivityCategoryToken) {
        print("Extend for app in category: \(category)")
    }

    private func openBonsai(webDomain: WebDomainToken) {
        print("Extend for app in web domain: \(webDomain)")
    }
}
