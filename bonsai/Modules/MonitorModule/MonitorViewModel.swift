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
    @Published var pickerIsPresented: Bool = false
    @Published var monitoringStarted: Bool = false
    @Published var timeLimitMinutesString: String = "1"
    @Published var enteredPin: String = ""
    @Published var pinError: String? = nil
    @Published var activitySelection = FamilyActivitySelection()
    @Published var purchaseSuccessful = false

    private let userDefaultsKey = "SelectedActivity"
    private let appGroupID = "group.com.bonsai"
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    // Product ID for the in-app purchase
    private let productID = "com.azam.bonsai.screentimemanualoverride"
    private var product: Product?

    init() {
        Task {
            await fetchProduct()
        }
    }

    public func startMonitoring() {
        let center = DeviceActivityCenter()

        guard let timeLimitMinutes = Int(timeLimitMinutesString), timeLimitMinutes > 0 else {
            print("Invalid or negative time limit input.")
            return
        }

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )

        let event = DeviceActivityEvent(
            applications: activitySelection.applicationTokens,
            categories: activitySelection.categoryTokens,
            webDomains: activitySelection.webDomainTokens,
            threshold: DateComponents(minute: timeLimitMinutes)
        )

        let activityName = DeviceActivityName("ScreenTimeActivity")
        let eventName = DeviceActivityEvent.Name("ScreenTimeThreshold")

        do {
            try center.stopMonitoring([activityName]) // Stop any previous monitoring session
            print("Stopped previous session if any.")

            let encoded = try JSONEncoder().encode(activitySelection)
            sharedDefaults?.set(encoded, forKey: userDefaultsKey)

            try center.startMonitoring(
                activityName,
                during: schedule,
                events: [eventName: event]
            )
            monitoringStarted = true
            print("Monitoring started successfully.")
        } catch {
            print("Failed to start monitoring: \(error.localizedDescription)")
        }
    }

    public func clearAllRestrictions() {
        let store = ManagedSettingsStore()
        store.shield.applicationCategories = nil
        store.shield.applications = nil
        monitoringStarted = false
    }

    public func validateAndExtendTime() {
        if enteredPin == UserDefaults.standard.string(forKey: LocalStorageKeys.timeExtensionRequestCode) {
            pinError = nil

            let center = DeviceActivityCenter()
            do {
                try center.stopMonitoring([DeviceActivityName("ScreenTimeActivity")])
                print("Stopped existing monitoring session.")
            } catch {
                print("Failed to stop monitoring: \(error)")
            }

            let currentLimit = Int(timeLimitMinutesString) ?? 1
            let newLimit = currentLimit + 15
            timeLimitMinutesString = String(newLimit)

            startMonitoring()
            UserDefaults.standard.removeObject(forKey: "timeExtensionRequestCode")
        } else {
            pinError = "Invalid PIN. Please try again."
        }
    }

    public func saveSelection(for selection: FamilyActivitySelection) {
        activitySelection = selection
    }

    // MARK: - In-App Purchase Methods
    public func fetchProduct() async {
        do {
            let products = try await Product.products(for: [productID])
            if let fetchedProduct = products.first {
                product = fetchedProduct
                print("Product fetched: \(fetchedProduct.displayName)")
            } else {
                print("No products found.")
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
}
