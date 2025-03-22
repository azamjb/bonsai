//
//  ScreenTimeService.swift
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
    public var id: UUID
    var givenName: String
    var appTokens: Set<ApplicationToken> = []
    var categoryTokens: Set<ActivityCategoryToken> = []
    var webDomainTokens: Set<WebDomainToken> = []
    var hours: Int
    var minutes: Int
    var weekdays: Set<Weekday>
    // An invisble limit is one that is set after they get an app unblocked from an accountability partner code. This bool tells us it isn't to be shown as a limit.
    let invisibleLimit: Bool
}

public enum Weekday: Int, CaseIterable, Codable {
    case sunday = 1, monday = 2, tuesday = 3, wednesday = 4, thursday = 5, friday = 6, saturday = 7
    
    static var today: Weekday {
        let today = Date()
        let calendar = Calendar.current
        return Weekday(rawValue: calendar.component(.weekday, from: today))!
    }
    
    var fullName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }

    var label: String {
        switch self {
        case .sunday: return "S"
        case .monday: return "M"
        case .tuesday: return "T"
        case .wednesday: return "W"
        case .thursday: return "T"
        case .friday: return "F"
        case .saturday: return "S"
        }
    }
}

public class ScreenTimeService: ObservableObject {
    public var code: String = ""
    public var timeExtensionRequestCode: String? = nil
    public var enteredPin: String = ""
    public var isSendingTimeRequest: Bool = false
    public var sentTimeRequest: Bool = false
    public var monitoringStarted: Bool = false
    public var purchaseSuccessful: Bool = false
    public var timeLimitMinutes: Int? = nil
    public let defaultLimitGroupName: String = "Limit Group"
    
    @Published public var limitsSet: [ScreenTimeActivityEvent] = []
    @Published public var limitsReached: [ScreenTimeActivityEvent] = []
    @Published public var pinError: String? = nil
    @Published public var timeRequestErrorMessage: String = ""

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

    let center = DeviceActivityCenter()
    
    private let appGroupID = "group.com.bonsai"

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
        
        setGroupDisplays()
    }
    
    public func getGroupDisplay(displayType: GroupDisplayType) -> [ScreenTimeActivityEvent] {
        //removeAllLimitsFromUserDefaults()
        
        let filteredEvents = sharedDefaults!.dictionaryRepresentation()
            .filter { $0.key.hasPrefix(displayType.rawValue) }
            .compactMapValues { $0 as? Data }
        
        var events: [ScreenTimeActivityEvent] = []
        
        filteredEvents.forEach { data in
            let activityEvent = try! JSONDecoder().decode(ScreenTimeActivityEvent.self, from: data.value)
            
            events.append(activityEvent)
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
                    note: "",
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
    
    public func startMonitoring(limit: ScreenTimeActivityEvent) {
        
        if limitsSet.contains(where: { $0.id == limit.id }) {
            removeLimitById(id: limit.id)
        }
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )
        
        let activityName = limit.id.uuidString
        
        let encoded = try! JSONEncoder().encode(limit)
        sharedDefaults?.set(encoded, forKey: GroupDisplayType.limit.rawValue + activityName)
        
        if limit.weekdays.contains(Weekday.today) {
            try! center.startMonitoring(
                DeviceActivityName(activityName),
                during: schedule,
                events: [DeviceActivityEvent.Name("LimitEvent"): DeviceActivityEvent (
                    applications: activitySelection.applicationTokens,
                    categories: activitySelection.categoryTokens,
                    webDomains: activitySelection.webDomainTokens,
                    threshold: DateComponents(hour: limit.hours, second: limit.minutes)
                )]
            )
        }
        
        resetSelectedLimit()
        monitoringStarted = true
        
        setGroupDisplays()
    }
    
    public func resetSelectedLimit() {
        activitySelection = FamilyActivitySelection()
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
        setGroupDisplays()
    }
    
    public func setGroupDisplays() {
        limitsSet = getGroupDisplay(displayType: .limit)
        limitsReached = getGroupDisplay(displayType: .block)
    }
    
    // for testing
    private func removeAllLimitsFromUserDefaults() {
        let eventsToRemove = sharedDefaults!.dictionaryRepresentation()
            .filter { $0.key.hasPrefix(GroupDisplayType.limit.rawValue) || $0.key.hasPrefix(GroupDisplayType.block.rawValue) }
        
        eventsToRemove.forEach { event in
            sharedDefaults?.removeObject(forKey: event.key)
        }
    }
    
    public func validateExtensionCode(inputPin: String, correctPin: String, group: ScreenTimeActivityEvent) { // not in use
        if inputPin == correctPin {
            extendLimitForGroup(group: group)
            pinError = nil
        } else {
            pinError = "Invalid PIN"
        }
    }

    public func extendLimitForGroup(group: ScreenTimeActivityEvent) {
        // These 3 variables get reassigned with the tokens to extend for removal. Muatating these set doesn't properly update them in real-time with the change detection. Need to reassign.
        var shieldedApps = settingsStore.shield.applications ?? []
        var shieldedWebDomainTokens = settingsStore.shield.webDomains ?? []
        var shieldedCategoryTokens = getShieldedCategoryTokens()
        
        group.appTokens.forEach { token in
            shieldedApps.remove(token)
        }
        
        settingsStore.shield.applications = shieldedApps
        
        group.categoryTokens.forEach { token in
            shieldedCategoryTokens.remove(token)
        }
        
        settingsStore.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(shieldedCategoryTokens)
        
        group.webDomainTokens.forEach { token in
            shieldedWebDomainTokens.remove(token)
        }
        
        settingsStore.shield.webDomains = shieldedWebDomainTokens
        
        // Remove the current block local storage object before starting the new session
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
            givenName: group.givenName,
            appTokens: group.appTokens,
            categoryTokens: group.categoryTokens,
            webDomainTokens: group.webDomainTokens,
            hours: 0,
            minutes: 15,
            weekdays: [Weekday.today], // We only want this limit to be active for the current day
            invisibleLimit: true)
        
        let activityName = eventId.uuidString
        
        let encoded = try! JSONEncoder().encode(activityEvent)
        sharedDefaults?.set(encoded, forKey: GroupDisplayType.limit.rawValue + activityName)

        if activityEvent.weekdays.contains(Weekday.today) {
            try! center.startMonitoring(
                DeviceActivityName(activityName),
                during: schedule,
                events: [DeviceActivityEvent.Name("LimitEvent"): DeviceActivityEvent (
                    applications: group.appTokens,
                    categories: group.categoryTokens,
                    webDomains: group.webDomainTokens,
                    threshold: DateComponents(hour: 0, second: 15)
                )]
            )
        }
        
        setGroupDisplays()
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
    
    public func deleteLimit(limitId: UUID) {
        removeLimitById(id: limitId)
        setGroupDisplays()
    }
    
    private func removeLimitById(id: UUID) {
        sharedDefaults!.removeObject(forKey: GroupDisplayType.limit.rawValue + id.uuidString)
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
