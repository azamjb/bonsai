//
//  ScreenTimeService.swift
//  bonsai
//
//  Created by Brayden O on 2025-01-12.
//

import SwiftUI
import ManagedSettings
import DeviceActivity
import FamilyControls

public class ScreenTimeService: ObservableObject {
    public var code: String = ""
    public var timeExtensionRequestCode: String? = nil
    public var isSendingTimeRequest: Bool = false
    public var sentTimeRequest: Bool = false
    public var monitoringStarted: Bool = false
    public var purchaseSuccessful: Bool = false
    
    @Published public var boundariesSet: [Boundary] = []
    @Published public var boundariesSetToday: [Boundary] = []
    @Published public var boundariesReached: [Boundary] = []
    @Published public var pinError: String? = nil
    @Published public var timeRequestErrorMessage: String = ""

    private let settingsStore = ManagedSettingsStore()
    private let activityMonitor = DeviceActivityMonitor()
    private let activityCenter = DeviceActivityCenter()
    private let boundaryService = BoundaryService(storage: BoundaryStorageService(database: LocalDatabase.shared.databaseWriter))
    private let sentExtensionCodeService = SentExtensionCodeService(storage: SentExtensionCodeStorageService(database: LocalDatabase.shared.databaseWriter))
    private let dailyBoundaryExtensionService = DailyBoundaryExtensionService(storage: DailyBoundaryExtensionStorageService(database: LocalDatabase.shared.databaseWriter))

    let center = DeviceActivityCenter()
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: BONSAI_GROUP_NAME)
    }

    @AppStorage(ACCOUNTABILITY_PARTNER_NUMBER_STRING) private var accountabilityPartnerNumber: String?
    
    init() {
        setGroupDisplays()
    }
    
    public func getGroupDisplay(getBlockedOnly: Bool) -> [Boundary] {
        var boundaries = boundaryService.getBoundaries()
        
        if getBlockedOnly {
            boundaries = boundaries.filter({ $0.isBlocked })
        }
        
        return boundaries
    }

    public func generateRandomCode() -> String {
        let randomCode = Int.random(in: 100_000...999_999)
        return String(randomCode)
    }
    
    public func startMonitoring(boundary: Boundary) {
        // *** Test code for boundary resetting after 15 minutes
        
//        let testDurationMinutes = 15
//        let startDate = Calendar.current.date(byAdding: .second, value: 5, to: Date())!
//        let endDate   = Calendar.current.date(byAdding: .minute, value: testDurationMinutes, to: startDate)!
//        let startComps = Calendar.current.dateComponents([.hour, .minute, .second], from: startDate)
//        let endComps   = Calendar.current.dateComponents([.hour, .minute, .second], from: endDate)
        
        // ***
        
        let startComps = DateComponents(hour: 0, minute: 0, second: 0)
        let endComps = DateComponents(hour: 23, minute: 59, second: 59)

        let schedule = DeviceActivitySchedule(
            intervalStart: startComps,
            intervalEnd: endComps,
            repeats: true
        )
        
        do {
            try center.startMonitoring(
                DeviceActivityName(boundary.id.uuidString),
                during: schedule,
                events: [DeviceActivityEvent.Name(BOUNDARY_STRING): DeviceActivityEvent (
                    applications: boundary.appTokens,
                    categories: boundary.categoryTokens,
                    webDomains: boundary.webDomainTokens,
                    threshold: DateComponents(hour: boundary.hours, minute: boundary.minutes)
                    //threshold: DateComponents(second: 1)
                )]
            )
            
            boundaryService.upsertBoundary(boundary: boundary)
            monitoringStarted = true
            setGroupDisplays()
            updateLeftoverWeeklySaves()
        } catch {
            print("Failed to start monitoring boundaries. Error: \(error)")
        }
    }

    public func extendBlockedBoundary(boundaryId: UUID) {
        if var boundary = boundaryService.getBoundaryById(boundaryId: boundaryId) {
            
            // Unblock apps
            var shieldedApps = settingsStore.shield.applications ?? []
            boundary.appTokens.forEach { token in shieldedApps.remove(token) }
            settingsStore.shield.applications = shieldedApps
            
            // Unblock categories
            unblockCategories(boundary.categoryTokens)
            
            // Unblock web domains
            var shieldedWebDomainTokens = settingsStore.shield.webDomains ?? []
            boundary.webDomainTokens.forEach { token in shieldedWebDomainTokens.remove(token) }
            settingsStore.shield.webDomains = shieldedWebDomainTokens
            
            // Unblock boundary
            boundary.isBlocked = false
            boundaryService.upsertBoundary(boundary: boundary)
            
            let now = Date()
            dailyBoundaryExtensionService.addBoundaryIdToExtensions(boundaryId: boundaryId, extendedDateTimeUtc: now)
            
            if var existingExtensionCode = sentExtensionCodeService.getRecentSentExtensionCodeForBoundary(boundaryId: boundaryId) {
                existingExtensionCode.isCodeValid = false
                sentExtensionCodeService.upsertSentExtensionCode(SentExtensionCode: existingExtensionCode)
            }
            
            startMonitoringPostExtension(boundary: boundary)
        }
    }
    
    private func startMonitoringPostExtension(boundary: Boundary) {
        // if there's already an active interval for this boundary, get rid of it so stuff doesn't get messed up
        center.stopMonitoring([DeviceActivityName(boundary.id.uuidString + EXTENSION_SUFFIX_STRING)])

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )

        do {
            try center.startMonitoring(
                DeviceActivityName(boundary.id.uuidString + EXTENSION_SUFFIX_STRING),
                during: schedule,
                events: [
                    DeviceActivityEvent.Name(BOUNDARY_STRING): DeviceActivityEvent(
                        applications: boundary.appTokens,
                        categories: boundary.categoryTokens,
                        webDomains: boundary.webDomainTokens,
                        threshold: DateComponents(hour: 0, minute: 15)
                        //threshold: DateComponents(minute: 1)

                    )
                ]
            )
        } catch {
            print("Failed to start extension monitoring: \(error)")
        }
    }

    func unblockCategories(_ toUnblock: Set<ActivityCategoryToken>) {
        guard let policy = settingsStore.shield.applicationCategories else { return }

        switch policy {
        case .specific(var blocked, let except):
            blocked.subtract(toUnblock)
            settingsStore.shield.applicationCategories = blocked.isEmpty
                ? nil
                : .specific(blocked, except: except)

        case .all:
            break
        case .none:
            break
        @unknown default:
            break
        }
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

    public func addActiveExtensionCode(boundaryId: UUID, code: String) {
        let code = SentExtensionCode(id: UUID(), boundaryId: boundaryId, code: code, sentDateTimeUtc: Date())
        sentExtensionCodeService.addSentExtensionCode(sentExtensionCode: code)
    }
    
    public func getCodeForBoundaryId(boundaryId: UUID) -> String {
        return sentExtensionCodeService.getRecentSentExtensionCodeForBoundary(boundaryId: boundaryId)?.code ?? ""
    }
    
    private func updateLeftoverWeeklySaves() {
        if sharedDefaults?.object(forKey: REMAINING_BOUNDARY_EXTENSIONS_STRING) != nil {
            let leftoverSaves = sharedDefaults?.integer(forKey: REMAINING_BOUNDARY_EXTENSIONS_STRING) ?? 0
            sharedDefaults?.set(max(0, leftoverSaves - 1), forKey: REMAINING_BOUNDARY_EXTENSIONS_STRING) // This should never be able to go below 0 except for testing (why we're setting a minimum)
        } else {
            sharedDefaults?.set(1, forKey: REMAINING_BOUNDARY_EXTENSIONS_STRING) // Set to 1 because they've just used their first edit.
        }
    }

    public func getLeftoverWeeklySaves() -> Int {
        return sharedDefaults?.integer(forKey: REMAINING_BOUNDARY_EXTENSIONS_STRING) ?? 0
    }
    
    // This removes everything. Blocked apps, active monitoring sessions, and set boundaries. Basically a fresh start for testing + unbricks phone.
    public func clearAllRestrictions() {
        monitoringStarted = false
        clearShieldedApps()
        
        activityCenter.stopMonitoring(activityCenter.activities)
        
        boundaryService.removeAllBoundaries(center: center)
        setGroupDisplays()
    }
    
    public func clearShieldedApps() {
        settingsStore.shield.applicationCategories = nil
        settingsStore.shield.applications = nil
        settingsStore.shield.webDomains = nil
        settingsStore.shield.webDomainCategories = nil
        
        boundaryService.unblockAllBoundaries()
    }

    public func setGroupDisplays() {
        let boundaries = boundaryService.getBoundaries()

        boundariesSet = boundaries
        boundariesSetToday = boundaryService.getBoundariesForToday()
        boundariesReached = boundaries.filter { $0.isBlocked }
    }
    
    
    public func validateExtensionCode(inputPin: String, correctPin: String, boundary: Boundary) { // not in use
        if inputPin == correctPin {
            extendBlockedBoundary(boundaryId: boundary.id)
            pinError = nil
        } else {
            pinError = "Invalid PIN"
        }
    }
    
    public func deleteBoundary(boundaryId: UUID) {
        boundaryService.removeBoundary(boundaryId: boundaryId, settingsStore: settingsStore, center: center)
        setGroupDisplays()
    }
    
    public func getSentExtensionCodesAsBoundaryNameAndDateDict() -> [(String, Date)] {
        let tuple = sentExtensionCodeService.getSentExtensionCodes().compactMap({ sentCode in
            if let boundary = boundaryService.getBoundaryById(boundaryId: sentCode.boundaryId) {
                return (boundary.givenName, sentCode.sentDateTimeUtc)
            } else {
                return ("Deleted Boundary", sentCode.sentDateTimeUtc)
            }
        }).sorted(by: { $0.1 > $1.1 })
        
        return tuple
    }
    
    // MARK: Helpers
    private func getCurrentDateTimeAsString() -> String {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
        return dateFormatter.string(from: Date())
    }
}
