//
//  TimeExtensionService.swift
//  bonsai
//
//  Created by Brayden O on 2025-01-12.
//

import SwiftUI
import StoreKit
import ManagedSettings
import DeviceActivity
import FamilyControls

public enum GroupDisplayType: String {
    case limit = "LimitEvent+"
    case block = "BlockGroup+"
}

public struct ScreenTimeActivityEvent: Codable, Identifiable, Hashable {
    public let id: UUID
    let appTokens: Set<ApplicationToken>?
    let categoryTokens: Set<ActivityCategoryToken>?
    let webDomainTokens: Set<WebDomainToken>?
    let hours: Int
    let minutes: Int
    let invisibleLimit: Bool
}

public class TimeExtensionService: ObservableObject {
    public var code: String = ""
    public var timeRequestErrorMessage: String = ""
    public var timeExtensionRequestCode: String? = nil
    public var enteredPin: String = ""
    public var isSendingTimeRequest: Bool = false
    public var sentTimeRequest: Bool = false
    public var monitoringStarted: Bool = false
    public var purchaseSuccessful: Bool = false
    public var pinError: String? = nil
    public var timeLimitMinutes: Int? = nil
    public var limitHours: Int = 0
    public var limitMinutes: Int = 15

    public var activitySelection = FamilyActivitySelection()
    private let settingsStore = ManagedSettingsStore()
    private let activityMonitor = DeviceActivityMonitor()
    private let activityCenter = DeviceActivityCenter()

    // DeviceActivityMonitor constants
    let dayLongSchedule = DeviceActivitySchedule(
        intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
        intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
        repeats: true
    )

    private let appGroupID = "group.com.bonsai"
    let center = DeviceActivityCenter()

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    let activityName = DeviceActivityName("ScreenTimeActivity")
    let eventName = DeviceActivityEvent.Name("ScreenTimeThreshold")

    @AppStorage(LocalStorageKeys.AccountabilityPartnerNumber) private var accountabilityPartnerNumber: String?
    
    // Product ID for the in-app purchase
    private let productID = "com.azam.bonsai.screentimemanualoverride"
    private var product: Product?
    
    init() {
        Task { await fetchProduct() }
    }
    
    public func getGroupDisplay(displayType: GroupDisplayType) -> [ScreenTimeActivityEvent] {
        let filteredEvents = sharedDefaults!.dictionaryRepresentation()
            .filter { $0.key.hasPrefix(displayType.rawValue) }
            .compactMapValues { $0 as? Data }
        
        var events: [ScreenTimeActivityEvent] = []
        
        filteredEvents.forEach { data in
            let activityEvent = try! JSONDecoder().decode(ScreenTimeActivityEvent.self, from: data.value)
            
            if(!activityEvent.invisibleLimit) {
                events.append(activityEvent)
            }
        }
        
        return events
    }

    public func sendTimeRequest() async {
        let smsApi = SMSApi()
        code = generateRandomCode()
        
        do {
            try await smsApi.timeRequest(
                request: SMSRequest(
                    number: accountabilityPartnerNumber!,
                    username: "Azam",
                    accountabilityPartnerName: "Bob",
                    code: code
                )
            )
            
            timeExtensionRequestCode = code
            UserDefaults.standard.set(code, forKey: LocalStorageKeys.timeExtensionRequestCode) // set code in local
        } catch let error as StringError {
            timeRequestErrorMessage = error.message
        } catch {
            timeRequestErrorMessage = error.localizedDescription
        }
        
        isSendingTimeRequest = false
        sentTimeRequest = true
    }
    
    public func generateRandomCode() -> String {
        let randomCode = Int.random(in: 100_000...999_999)
        return String(randomCode)
    }
    
    public func startMonitoring() {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true)
        
        let eventId = UUID()
        
        let activityEvent = ScreenTimeActivityEvent(
            id: eventId,
            appTokens: activitySelection.applicationTokens,
            categoryTokens: activitySelection.categoryTokens,
            webDomainTokens: activitySelection.webDomainTokens,
            hours: limitHours,
            minutes: limitMinutes,
            invisibleLimit: false)
        
        let activityName = eventId.uuidString
        
        let encoded = try! JSONEncoder().encode(activityEvent)
        sharedDefaults?.set(encoded, forKey: GroupDisplayType.limit.rawValue + activityName)
        
        try! center.startMonitoring(
            DeviceActivityName(activityName),
            during: schedule,
            events: [DeviceActivityEvent.Name("LimitEvent"): DeviceActivityEvent (
                applications: activitySelection.applicationTokens,
                categories: activitySelection.categoryTokens,
                webDomains: activitySelection.webDomainTokens,
                threshold: DateComponents(hour: limitHours, second: limitMinutes)
            )]
        )

        resetLimitSelections()
        monitoringStarted = true
    }
    
    private func resetLimitSelections() {
        activitySelection = FamilyActivitySelection()
        limitHours = 0
        limitMinutes = 15
    }

    // This removes everything. Blocked apps, active monitoring sessions, and set limits. Basically a fresh start for testing + unbricks phone.
    public func clearAllRestrictions() {
        settingsStore.shield.applicationCategories = nil
        settingsStore.shield.applications = nil
        settingsStore.shield.webDomains = nil
        settingsStore.shield.webDomainCategories = nil
        
        monitoringStarted = false
        
        activityCenter.stopMonitoring(activityCenter.activities)
        
        removeAllLimitsFromUserDefaults()
    }
    
    // for testing
    private func removeAllLimitsFromUserDefaults() {
        let eventsToRemove = sharedDefaults!.dictionaryRepresentation()
            .filter { $0.key.hasPrefix("LimitEvent+") }
        
        eventsToRemove.forEach { event in
            sharedDefaults?.removeObject(forKey: event.key)
        }
    }
    
    public func validateExtensionCode(inputPin: String, correctPin: String, group: ScreenTimeActivityEvent) {
        print(inputPin, correctPin)
        if inputPin == correctPin {
            extendLimitForGroup(group: group)
            pinError = nil
        } else {
            pinError = "Invalid PIN"
        }
    }

    private func extendLimitForGroup(group: ScreenTimeActivityEvent) {
        // These 3 variables get reassigned with the tokens to extend for removed.
        var shieldedApps = settingsStore.shield.applications ?? []
        var shieldedWebDomainTokens = settingsStore.shield.webDomains ?? []
        var shieldedCategoryTokens = getShieldedCategoryTokens()
        
        print(group)
        if let groupAppTokens = group.appTokens {
            groupAppTokens.forEach { token in
                shieldedApps.remove(token)
            }
            
            settingsStore.shield.applications = shieldedApps
        }
        
        if let groupCategoryTokens = group.categoryTokens {
            groupCategoryTokens.forEach { token in
                shieldedCategoryTokens.remove(token)
            }
            
            settingsStore.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(shieldedCategoryTokens)
        }
        
        if let groupWebDomainTokens = group.webDomainTokens {
            groupWebDomainTokens.forEach { token in
                shieldedWebDomainTokens.remove(token)
            }
            
            settingsStore.shield.webDomains = shieldedWebDomainTokens
        }
        
        // Remove the current block local storage object before starting the new seshski
        sharedDefaults?.removeObject(forKey: GroupDisplayType.block.rawValue + group.id.uuidString)
        
        startMonitoringPostExtension(group: group)
    }
    
    private func startMonitoringPostExtension(group: ScreenTimeActivityEvent) {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true)
        
        let eventId = UUID()
        
        let activityEvent = ScreenTimeActivityEvent(
            id: eventId,
            appTokens: group.appTokens,
            categoryTokens: group.categoryTokens,
            webDomainTokens: group.webDomainTokens,
            hours: 0,
            minutes: 15,
            invisibleLimit: true)
        
        let activityName = eventId.uuidString
        
        let encoded = try! JSONEncoder().encode(activityEvent)
        sharedDefaults?.set(encoded, forKey: GroupDisplayType.limit.rawValue + activityName)

        try! center.startMonitoring(
            DeviceActivityName(activityName),
            during: schedule,
            events: [DeviceActivityEvent.Name("LimitEvent"): DeviceActivityEvent (
                applications: group.appTokens ?? [],
                categories: group.categoryTokens ?? [],
                webDomains: group.webDomainTokens ?? [],
                threshold: DateComponents(hour: 0, second: 15)
            )]
        )
    }
    
    private func getShieldedCategoryTokens() -> Set<ActivityCategoryToken> {
        if let categories = settingsStore.shield.applicationCategories {
            switch categories {
            case .none:
                return []
            case .specific(let specificCategories, _):
                return specificCategories
            case .all(except: _):
                return []
            @unknown default:
                return []
            }
        }
        
        return []
    }
    
    // MARK: - In-App Purchase Methods
    public func fetchProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            if let fetchedProduct = products.first {
                product = fetchedProduct
                print("Product fetched: \(fetchedProduct.displayName)")
            } else {
                //print("No products found.")
            }
        } catch {
            print("Error fetching product: \(error)")
        }
    }

    public func purchaseManualOverride() async {
        guard let product = product else {
            print("Product not loaded.")
            return
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    print("Purchase successful!")
                    purchaseSuccessful = true
                    clearAllRestrictions() // Clear restrictions after successful purchase
                    await transaction.finish()
                case .unverified(_, let error):
                    print("Transaction verification failed: \(error.localizedDescription)")
                }
            case .pending:
                print("Purchase pending.")
            case .userCancelled:
                print("Purchase cancelled.")
            @unknown default:
                print("Unknown purchase result.")
            }
        } catch {
            print("Purchase failed: \(error.localizedDescription)")
        }
    }
    
    // MARK: Helpers
    private func getCurrentDateTimeAsString() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        return dateFormatter.string(from: Date())
    }
}
