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

enum BlockTypes: String {
    case app
    case category
    case webDomain
}

public struct ScreenTimeActivityEvent: Codable {
    let appTokens: Set<ApplicationToken>?
    let categoryTokens: Set<ActivityCategoryToken>?
    let webDomainTokens: Set<WebDomainToken>?
    let hours: Int
    let minutes: Int
}

// To show the ScreenTimeActivityEvent in the UI it must be Identifiable
public struct IdentifiableScreenTimeActivityEvent: Identifiable {
    public let id = UUID()
    let screenTimeActivityEvent: ScreenTimeActivityEvent
}

public class TimeExtensionService {
    public var code: String = ""
    public var timeRequestErrorMessage: String = ""
    public var enteredPin: String = ""
    public var isSendingTimeRequest: Bool = false
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
    
    public func getActiveLimitsDisplay() -> [IdentifiableScreenTimeActivityEvent] {
        let filteredEvents = sharedDefaults!.dictionaryRepresentation()
            .filter { $0.key.hasPrefix("LimitEvent+") }
            .compactMapValues { $0 as? Data }
        
        var events: [IdentifiableScreenTimeActivityEvent] = []
        
        filteredEvents.forEach { data in
            let activityEvent = try! JSONDecoder().decode(ScreenTimeActivityEvent.self, from: data.value)
            
            events.append(IdentifiableScreenTimeActivityEvent(screenTimeActivityEvent: activityEvent))
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
            UserDefaults.standard.set(code, forKey: LocalStorageKeys.timeExtensionRequestCode) // set code in local
        } catch let error as StringError {
            timeRequestErrorMessage = error.message
        } catch {
            timeRequestErrorMessage = error.localizedDescription
        }
        
        isSendingTimeRequest = false
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
        
        center.stopMonitoring(center.activities)
        
        // This needs to be unique
        let activtyName = getCurrentDateTimeAsString().replacingOccurrences(of: " ", with: "")
        
        let activityEvent = ScreenTimeActivityEvent(
            appTokens: activitySelection.applicationTokens,
            categoryTokens: activitySelection.categoryTokens,
            webDomainTokens: activitySelection.webDomainTokens,
            hours: limitHours,
            minutes: limitMinutes)
        
        let encoded = try! JSONEncoder().encode(activityEvent)
        sharedDefaults?.set(encoded, forKey: "LimitEvent+" + activtyName)
        
        try! center.startMonitoring(
            DeviceActivityName(activtyName),
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

    public func validateAndExtendTime() {
        if enteredPin == UserDefaults.standard.string(forKey: LocalStorageKeys.timeExtensionRequestCode) {
            pinError = nil

            let center = DeviceActivityCenter()
            center.stopMonitoring([DeviceActivityName("ScreenTimeActivity")])

//            let currentLimit = Int(timeLimitMinutesString) ?? 1
//            let newLimit = currentLimit + 15
//            timeLimitMinutesString = String(newLimit)
//
//            startMonitoring()
            UserDefaults.standard.removeObject(forKey: "timeExtensionRequestCode")
        } else {
            pinError = "Invalid PIN. Please try again."
        }
    }

    public func extendLimitForToken(appToken: ApplicationToken) {
        // Remove the token from the set of currently shielded token
        var appTokens = Array(settingsStore.shield.applications!)
        
        appTokens.removeAll { $0 == appToken }
        settingsStore.shield.applications = Set(appTokens)
        
        // Create the monitoring sesh
        let event = DeviceActivityEvent (
            applications: [appToken],
            threshold: DateComponents(minute: 2) // Figure out how long we actually want to extend for
        )
        
        do {
            try activityCenter.startMonitoring(
                activityName,
                during: dayLongSchedule,
                events: [eventName: event]
            )
        } catch {
           print("Failed to start monitoring session.")
        }
    }
    
    public func extendLimitForToken(categoryToken: ActivityCategoryToken) {
        
    }
    
    public func extendLimitForToken(webDomainToken: WebDomainToken) {
        
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
