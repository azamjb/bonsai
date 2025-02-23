//
//  delete.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-02-09.
//

//
//import SwiftUI
//import StoreKit
//import ManagedSettings
//import DeviceActivity
//import FamilyControls
//
//public enum GroupDisplayType: String {
//    case limit = "LimitEvent+"
//    case block = "BlockGroup+"
//}
//
//public struct ScreenTimeActivityEvent: Codable, Identifiable, Hashable {
//    public let id: UUID
//    let appTokens: Set<ApplicationToken>?
//    let categoryTokens: Set<ActivityCategoryToken>?
//    let webDomainTokens: Set<WebDomainToken>?
//    let hours: Int
//    let minutes: Int
//    let invisibleLimit: Bool
//}
//
//public class TimeExtensionService: ObservableObject {
//    public var code: String = ""
//    public var timeRequestErrorMessage: String = ""
//    public var timeExtensionRequestCode: String? = nil
//    public var enteredPin: String = ""
//    public var isSendingTimeRequest: Bool = false
//    public var sentTimeRequest: Bool = false
//    public var monitoringStarted: Bool = false
//    public var purchaseSuccessful: Bool = false
//    public var pinError: String? = nil
//    public var timeLimitMinutes: Int? = nil
//    public var limitHours: Int = 0
//    public var limitMinutes: Int = 15
//    
//    public var activitySelection = FamilyActivitySelection()
//    private let settingsStore = ManagedSettingsStore()
//    private let activityMonitor = DeviceActivityMonitor()
//    private let activityCenter = DeviceActivityCenter()
//    
//    // DeviceActivityMonitor constants
//    let dayLongSchedule = DeviceActivitySchedule(
//        intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
//        intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
//        repeats: true
//    )
//    
//    private let appGroupID = "group.com.bonsai"
//    let center = DeviceActivityCenter()
//    
//    private var sharedDefaults: UserDefaults? {
//        UserDefaults(suiteName: appGroupID)
//    }
//    
//    let activityName = DeviceActivityName("ScreenTimeActivity")
//    let eventName = DeviceActivityEvent.Name("ScreenTimeThreshold")
//    
//    @AppStorage(LocalStorageKeys.AccountabilityPartnerNumber) private var accountabilityPartnerNumber: String?
//    
//    // Product ID for the in-app purchase
//    private let productID = "com.azam.bonsai.screentimemanualoverride"
//    private var product: Product?
//    
//    init() {
//        Task { await fetchProduct() }
//    }
//    
//    public func getGroupDisplay(displayType: GroupDisplayType) -> [ScreenTimeActivityEvent] {
//        let filteredEvents = sharedDefaults!.dictionaryRepresentation()
//            .filter { $0.key.hasPrefix(displayType.rawValue) }
//            .compactMapValues { $0 as? Data }
//        
//        var events: [ScreenTimeActivityEvent] = []
//        
//        filteredEvents.forEach { data in
//            let activityEvent = try! JSONDecoder().decode(ScreenTimeActivityEvent.self, from: data.value)
//            
//            if(!activityEvent.invisibleLimit) {
//                events.append(activityEvent)
//            }
//        }
//        
//        return events
//    }
//    
//    public func sendTimeRequest() async {
//        let smsApi = SMSApi()
//        code = generateRandomCode()
//        
//        do {
//            try await smsApi.timeRequest(
//                request: SMSRequest(
//                    number: accountabilityPartnerNumber!,
//                    username: "Azam",
//                    accountabilityPartnerName: "Bob",
//                    code: code
//                )
//            )
//            
//            timeExtensionRequestCode = code
//            UserDefaults.standard.set(code, forKey: LocalStorageKeys.timeExtensionRequestCode) // set code in local
//        } catch let error as StringError {
//            timeRequestErrorMessage = error.message
//        } catch {
//            timeRequestErrorMessage = error.localizedDescription
//        }
//        
//        isSendingTimeRequest = false
//        sentTimeRequest = true
//    }
//
//    
//    public func startMonitoring() {
//        let schedule = DeviceActivitySchedule(
//            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
//            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
//            repeats: true)
//        
//        let eventId = UUID()
//        
//        let activityEvent = ScreenTimeActivityEvent(
//            id: eventId,
//            appTokens: activitySelection.applicationTokens,
//            categoryTokens: activitySelection.categoryTokens,
//            webDomainTokens: activitySelection.webDomainTokens,
//            hours: limitHours,
//            minutes: limitMinutes,
//            invisibleLimit: false)
//        
//        let activityName = eventId.uuidString
//        
//        let encoded = try! JSONEncoder().encode(activityEvent)
//        sharedDefaults?.set(encoded, forKey: GroupDisplayType.limit.rawValue + activityName)
//        
//        try! center.startMonitoring(
//            DeviceActivityName(activityName),
//            during: schedule,
//            events: [DeviceActivityEvent.Name("LimitEvent"): DeviceActivityEvent (
//                applications: activitySelection.applicationTokens,
//                categories: activitySelection.categoryTokens,
//                webDomains: activitySelection.webDomainTokens,
//                threshold: DateComponents(hour: limitHours, second: limitMinutes)
//            )]
//        )
//        
//        resetLimitSelections()
//        monitoringStarted = true
//    }
//    
//    private func resetLimitSelections() {
//        activitySelection = FamilyActivitySelection()
//        limitHours = 0
//        limitMinutes = 15
//    }
//    
//
//    // for testing
//    private func removeAllLimitsFromUserDefaults() {
//        let eventsToRemove = sharedDefaults!.dictionaryRepresentation()
//            .filter { $0.key.hasPrefix("LimitEvent+") }
//        
//        eventsToRemove.forEach { event in
//            sharedDefaults?.removeObject(forKey: event.key)
//        }
//    }
//
//    
//    private func extendLimitForGroup(group: ScreenTimeActivityEvent) {
//        // These 3 variables get reassigned with the tokens to extend for removed.
//        var shieldedApps = settingsStore.shield.applications ?? []
//        var shieldedWebDomainTokens = settingsStore.shield.webDomains ?? []
//        var shieldedCategoryTokens = getShieldedCategoryTokens()
//        
//        print(group)
//        if let groupAppTokens = group.appTokens {
//            groupAppTokens.forEach { token in
//                shieldedApps.remove(token)
//            }
//            
//            settingsStore.shield.applications = shieldedApps
//        }
//        
//        if let groupCategoryTokens = group.categoryTokens {
//            groupCategoryTokens.forEach { token in
//                shieldedCategoryTokens.remove(token)
//            }
//            
//            settingsStore.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(shieldedCategoryTokens)
//        }
//        
//        if let groupWebDomainTokens = group.webDomainTokens {
//            groupWebDomainTokens.forEach { token in
//                shieldedWebDomainTokens.remove(token)
//            }
//            
//            settingsStore.shield.webDomains = shieldedWebDomainTokens
//        }
//        
//        // Remove the current block local storage object before starting the new seshski
//        sharedDefaults?.removeObject(forKey: GroupDisplayType.block.rawValue + group.id.uuidString)
//        
//        startMonitoringPostExtension(group: group)
//    }
//    
//    private func startMonitoringPostExtension(group: ScreenTimeActivityEvent) {
//        let schedule = DeviceActivitySchedule(
//            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
//            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
//            repeats: true)
//        
//        let eventId = UUID()
//        
//        let activityEvent = ScreenTimeActivityEvent(
//            id: eventId,
//            appTokens: group.appTokens,
//            categoryTokens: group.categoryTokens,
//            webDomainTokens: group.webDomainTokens,
//            hours: 0,
//            minutes: 15,
//            invisibleLimit: true)
//        
//        let activityName = eventId.uuidString
//        
//        let encoded = try! JSONEncoder().encode(activityEvent)
//        sharedDefaults?.set(encoded, forKey: GroupDisplayType.limit.rawValue + activityName)
//        
//        try! center.startMonitoring(
//            DeviceActivityName(activityName),
//            during: schedule,
//            events: [DeviceActivityEvent.Name("LimitEvent"): DeviceActivityEvent (
//                applications: group.appTokens ?? [],
//                categories: group.categoryTokens ?? [],
//                webDomains: group.webDomainTokens ?? [],
//                threshold: DateComponents(hour: 0, second: 15)
//            )]
//        )
//    }
//    
//    private func getShieldedCategoryTokens() -> Set<ActivityCategoryToken> {
//        if let categories = settingsStore.shield.applicationCategories {
//            switch categories {
//            case .none:
//                return []
//            case .specific(let specificCategories, _):
//                return specificCategories
//            case .all(except: _):
//                return []
//            @unknown default:
//                return []
//            }
//        }
//        
//        return []
//    }
//
//
//    
//    // MARK: Helpers
//    private func getCurrentDateTimeAsString() -> String {
//        let dateFormatter : DateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
//        return dateFormatter.string(from: Date())
//    }
//}
