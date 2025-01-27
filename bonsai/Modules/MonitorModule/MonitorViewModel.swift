//
//  MonitorViewModel.swift
//  bonsai
//
//  Created by Brayden O on 2025-01-01.
//

import Combine
import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings
import StoreKit

@MainActor
class MonitorViewModel: ObservableObject {
    @Published var monitoringStarted: Bool = false
    @Published var timeLimitMinutesString: String = "1"
    @Published var enteredPin: String = ""
    @Published var pinError: String? = nil
    @Published var purchaseSuccessful = false
    @Published var blockedApps: Set<ApplicationToken> = []
    @Published var blockedCategories: Set<ActivityCategoryToken> = []
    @Published var blockedWebDomains: Set<WebDomainToken> = []

    // Product ID for the in-app purchase
    private let productID = "com.azam.bonsai.screentimemanualoverride"
    private var product: Product?
    
    public func setBlockedAppsDisplayed() {
        let settingStore = ManagedSettingsStore()
        blockedApps = settingStore.shield.applications ?? []
    }
    
    public func setBlockedCategoriesDisplayed() {
        let settingStore = ManagedSettingsStore()
        
        switch settingStore.shield.applicationCategories {
            case .specific(let categoryTokens, _):
                blockedCategories = categoryTokens
            case .all:
                blockedCategories = []
            case .some(_):
                blockedCategories = []
            case nil:
                blockedCategories = []
            @unknown default:
                blockedCategories = []
        }
    }
    
    public func setBlockedWebDomainsDisplayed() {
        let settingStore = ManagedSettingsStore()
        blockedWebDomains = settingStore.shield.webDomains ?? []
    }
    
    public func updateBlocksDisplayed() {
        setBlockedAppsDisplayed()
        setBlockedCategoriesDisplayed()
        setBlockedWebDomainsDisplayed()
    }
    
    // TODO
    public func onExtendPressed(appToken: ApplicationToken?, categoryToken: ActivityCategoryToken?, webToken: WebDomainToken?) {
        if(appToken != nil) {
            
        } else if (categoryToken != nil) {
            
        } else if (webToken != nil) {
            
        }
    }
}
 
