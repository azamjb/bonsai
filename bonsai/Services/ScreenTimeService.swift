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

public class ScreenTimeService: ObservableObject {
    public var code: String = ""
    public var timeExtensionRequestCode: String? = nil
    public var isSendingTimeRequest: Bool = false
    public var sentTimeRequest: Bool = false
    public var monitoringStarted: Bool = false
    public var purchaseSuccessful: Bool = false
    
    @Published public var boundariesSet: [Boundary] = []
    @Published public var boundariesReached: [Boundary] = []
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

    @AppStorage(ACCOUNTABILITY_PARTNER_NUMBER) private var accountabilityPartnerNumber: String?
    
    // Product ID for the in-app purchase
    private let productID = "com.azam.bonsai.screentimemanualoverride"
    private var product: Product?
    
    init() {
        Task { await fetchProduct() }
        
        setGroupDisplays()
    }
    
    public func getGroupDisplay(getBlockedOnly: Bool) -> [Boundary] {
        var boundaries = getBoundariesFromUserDefaults()
        
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
        if boundariesSet.contains(where: { $0.id == boundary.id }) {
            removeBoundaryById(id: boundary.id)
        }
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )
        
        addBoundaryToUserDefaults(boundary: boundary)
        
        if boundary.weekdays.contains(Weekday.today) {
            try! center.startMonitoring(
                DeviceActivityName(boundary.id.uuidString),
                during: schedule,
                events: [DeviceActivityEvent.Name("Boundary"): DeviceActivityEvent (
                    applications: activitySelection.applicationTokens,
                    categories: activitySelection.categoryTokens,
                    webDomains: activitySelection.webDomainTokens,
                    threshold: DateComponents(hour: boundary.hours, second: boundary.minutes)
                )]
            )
        }
        
        resetSelectedBoundary()
        monitoringStarted = true
        
        setGroupDisplays()
        updateLeftoverWeeklySaves()
    }
    
    public func getBoundaryById(id: UUID) -> Boundary? {
        let boundaries = getBoundariesFromUserDefaults()
        
        if boundaries.count > 0 {
            let boundary = boundaries.first { boundary in return boundary.id == id }
            return boundary
        } else {
            return nil
        }
    }
    
    public func getBoundariesFromUserDefaults() -> [Boundary] {
        guard let defaults = sharedDefaults else {
            print("❌ sharedDefaults is nil — did you forget to set up your App Group?")
            return []
        }

        if let data = defaults.data(forKey: BOUNDARIES_STRING) {
            do {
                let decodedBoundaries = try JSONDecoder().decode([Boundary].self, from: data)
                return decodedBoundaries
            } catch {
                print("❌ Failed to decode boundaries: \(error.localizedDescription)")
                return []
            }
        } else {
            let freshBoundaries: [Boundary] = []
            do {
                let encoded = try JSONEncoder().encode(freshBoundaries)
                defaults.set(encoded, forKey: BOUNDARIES_STRING)
            } catch {
                print("❌ Failed to encode empty boundary list: \(error.localizedDescription)")
            }
            return []
        }
    }
    
    public func getSentExtensionCodes() -> [SentExtensionCodeModel] {
        if let data = sharedDefaults!.data(forKey: SENT_EXTENSION_CODES_STRING) {
            do {
                let activeCodeModel = try JSONDecoder().decode([SentExtensionCodeModel].self, from: data)
                return activeCodeModel
            } catch {
                print("failed to decode")
                return []
            }
        } else {
            print("non")
            return []
        }
    }

    public func addActiveExtensionCode(boundaryId: UUID, code: String) {
        var sentExtensionCodeModels = getSentExtensionCodes()
        
        sentExtensionCodeModels = sentExtensionCodeModels.map({ model in
            var updatedModel = model
            
            if updatedModel.boundaryId == boundaryId {
                updatedModel.isCodeValid = false
            }
            
            return updatedModel
        })

        sentExtensionCodeModels.append(SentExtensionCodeModel(boundaryId: boundaryId, code: code, sentDateTimeUtc: Date()))

        sharedDefaults!.set(try! JSONEncoder().encode(sentExtensionCodeModels), forKey: SENT_EXTENSION_CODES_STRING)
    }
    
    public func getCodeForBoundaryId(boundaryId: UUID) -> String {
        let activeExtensionModels = getSentExtensionCodes()
        
        return activeExtensionModels.first(where: { $0.boundaryId == boundaryId })?.code ?? ""
    }
    
    private func updateLeftoverWeeklySaves() {
        if sharedDefaults!.object(forKey: REMAINING_BOUNDARY_EXTENSIONS_STRING) != nil {
            let leftoverSaves = sharedDefaults!.integer(forKey: REMAINING_BOUNDARY_EXTENSIONS_STRING)
            sharedDefaults?.set(max(0, leftoverSaves - 1), forKey: REMAINING_BOUNDARY_EXTENSIONS_STRING) // This should never be able to go below 0 except for testing (why we're setting a minimum)
        } else {
            sharedDefaults?.set(1, forKey: REMAINING_BOUNDARY_EXTENSIONS_STRING) // Set to 1 because they've just used their first edit.
        }
    }
    
    public func getLeftoverWeeklySaves() -> Int {
        return sharedDefaults!.integer(forKey: REMAINING_BOUNDARY_EXTENSIONS_STRING)
    }
    
    public func getDailyBoundaryExtensionsModels() -> [DailyBoundaryExtensionsModel] {
        if let dailyExtensionsData = sharedDefaults!.data(forKey: DAILY_BOUNDARY_EXTENSIONS_STRING) {
            do {
                let dailyExtensionsModels  = try JSONDecoder().decode([DailyBoundaryExtensionsModel].self, from: dailyExtensionsData)
                return dailyExtensionsModels
            } catch {
                sharedDefaults?.removeObject(forKey: DAILY_BOUNDARY_EXTENSIONS_STRING)
                return []
            }
        } else {
            let emptyArr: [DailyBoundaryExtensionsModel] = []
            
            let encoded = try! JSONEncoder().encode(emptyArr)
            sharedDefaults?.set(encoded, forKey: DAILY_BOUNDARY_EXTENSIONS_STRING)
            
            return []
        }
    }

    public func resetSelectedBoundary() {
        activitySelection = FamilyActivitySelection()
    }

    // This removes everything. Blocked apps, active monitoring sessions, and set boundaries. Basically a fresh start for testing + unbricks phone.
    public func clearAllRestrictions() {
        monitoringStarted = false
        clearShieldedApps()
        
        activityCenter.stopMonitoring(activityCenter.activities)
        
        removeAllBoundariesFromUserDefaults()
        setGroupDisplays()
    }
    
    public func clearShieldedApps() {
        settingsStore.shield.applicationCategories = nil
        settingsStore.shield.applications = nil
        settingsStore.shield.webDomains = nil
        settingsStore.shield.webDomainCategories = nil
    }

    public func setGroupDisplays() {
        boundariesSet = getGroupDisplay(getBlockedOnly: false)
        boundariesReached = getGroupDisplay(getBlockedOnly: true)
    }
    
    // for testing
    private func removeAllBoundariesFromUserDefaults() {
        sharedDefaults!.set([], forKey: BOUNDARIES_STRING)
    }
    
    public func validateExtensionCode(inputPin: String, correctPin: String, boundary: Boundary) { // not in use
        if inputPin == correctPin {
            extendBlockedBoundary(boundaryId: boundary.id)
            pinError = nil
        } else {
            pinError = "Invalid PIN"
        }
    }

    public func extendBlockedBoundary(boundaryId: UUID) {
        
        if let boundary = getBoundaryById(id: boundaryId) {
            // These 3 variables get reassigned with the tokens to extend for removal. Muatating these set doesn't properly update them in real-time with the change detection. Need to reassign.
            var shieldedApps = settingsStore.shield.applications ?? []
            var shieldedWebDomainTokens = settingsStore.shield.webDomains ?? []
            var shieldedCategoryTokens = getShieldedCategoryTokens()
            
            boundary.appTokens.forEach { token in
                shieldedApps.remove(token)
            }
            
            settingsStore.shield.applications = shieldedApps
            
            boundary.categoryTokens.forEach { token in
                shieldedCategoryTokens.remove(token)
            }
            
            settingsStore.shield.applicationCategories = ShieldSettings.ActivityCategoryPolicy.specific(shieldedCategoryTokens)
            
            boundary.webDomainTokens.forEach { token in
                shieldedWebDomainTokens.remove(token)
            }
            
            settingsStore.shield.webDomains = shieldedWebDomainTokens
            
            let updatedBoundaries = getBoundariesFromUserDefaults().map { currentBoundary in
                var updatedBoundary = currentBoundary
                if currentBoundary.id == boundary.id {
                    updatedBoundary.isBlocked = false
                }
                return updatedBoundary
            }
            
            sharedDefaults!.set(try! JSONEncoder().encode(updatedBoundaries), forKey: BOUNDARIES_STRING)
            startMonitoringPostExtension(boundary: boundary)
        }
    }
    
    private func startMonitoringPostExtension(boundary: Boundary) {
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true)
        
        var boundaryToExtend = boundary
        
        boundaryToExtend.isBlocked = false
        updateExistingBoundaryInUserDefaults(updatedBoundary: boundaryToExtend)
        
        if boundary.weekdays.contains(Weekday.today) {
            try! center.startMonitoring(
                DeviceActivityName(boundary.id.uuidString),
                during: schedule,
                events: [DeviceActivityEvent.Name("Boundary"): DeviceActivityEvent (
                    applications: boundary.appTokens,
                    categories: boundary.categoryTokens,
                    webDomains: boundary.webDomainTokens,
                    threshold: DateComponents(hour: 0, minute: 15)
                )]
            )
        }
        
        setGroupDisplays()
        addBoundaryIdToExtensionModels(id: boundaryToExtend.id)
    }
    
    private func addBoundaryIdToExtensionModels(id: UUID) {
        var dailyExtensionsModels = getDailyBoundaryExtensionsModels()
        dailyExtensionsModels.append(DailyBoundaryExtensionsModel(boundaryId: id, extendedDateTimeUtc: Date()))
        
        let encoded = try! JSONEncoder().encode(dailyExtensionsModels)
        
        sharedDefaults!.set(encoded, forKey: DAILY_BOUNDARY_EXTENSIONS_STRING)
        sharedDefaults!.synchronize()
    }
    
    private func addBoundaryToUserDefaults(boundary: Boundary) {
        var boundaries = getBoundariesFromUserDefaults()
        boundaries.append(boundary)
        sharedDefaults!.set(try! JSONEncoder().encode(boundaries), forKey: BOUNDARIES_STRING)
    }
    
    private func updateExistingBoundaryInUserDefaults(updatedBoundary: Boundary) {
        let boundaries = getBoundariesFromUserDefaults()
        
        let updatedBoundaries = boundaries.map { boundary in
            if boundary.id == updatedBoundary.id {
                return updatedBoundary
            }
            
            return boundary
        }
        
        sharedDefaults!.set(try! JSONEncoder().encode(updatedBoundaries), forKey: BOUNDARIES_STRING)
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
    
    public func deleteBoundary(boundaryId: UUID) {
        removeBoundaryById(id: boundaryId)
        setGroupDisplays()
    }
    
    public func getSentExtensionCodesAsBoundaryNameAndDateDict() -> [(String, Date)] {
        let tuple = getSentExtensionCodes().compactMap({ sentCode in
            if let boundary = getBoundaryById(id: sentCode.boundaryId) {
                return (boundary.givenName, sentCode.sentDateTimeUtc)
            } else {
                return ("Deleted Boundary", sentCode.sentDateTimeUtc)
            }
        }).sorted(by: { $0.1 < $1.1 })
        
        return tuple
    }

    private func removeBoundaryById(id: UUID) {
        let allBoundaries = getBoundariesFromUserDefaults()
        
        guard let targetBoundary = allBoundaries.first(where: { $0.id == id }) else {
            return
        }
        
        let filteredBoundaries = allBoundaries.filter({ $0.id != id })
        
        sharedDefaults?.set(try! JSONEncoder().encode(filteredBoundaries), forKey: BOUNDARIES_STRING)
        
        let currentBlockedApps = settingsStore.shield.applications ?? []
        settingsStore.shield.applications = currentBlockedApps.filter({ !targetBoundary.appTokens.contains($0) })
        
        let currentBlockedWebDomains = settingsStore.shield.webDomains ?? []
        settingsStore.shield.webDomains = currentBlockedWebDomains.filter({ !targetBoundary.webDomainTokens.contains($0) })
        
        if let categories = settingsStore.shield.applicationCategories {
            switch categories {
            case .none: break
            case .specific(let specificCategories, let exceptions):
                // You might also need to filter exceptions depending on your requirements
                let filteredCategories = specificCategories.filter({ !targetBoundary.categoryTokens.contains($0) })
                settingsStore.shield.applicationCategories = .specific(filteredCategories, except: exceptions)
            case .all: break
            @unknown default: break
            }
        }
        
        center.stopMonitoring([DeviceActivityName(id.uuidString)])
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
