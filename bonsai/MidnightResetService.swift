import Foundation
import ManagedSettings
import DeviceActivity
class MidnightResetService {
    static let shared = MidnightResetService()
    private let screenTime = ScreenTimeService()
    
    private let appGroupID = "group.com.bonsai"
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    func setupMidnightReset() {
        let center = DeviceActivityCenter()
        
        // Stop any existing monitoring
        center.stopMonitoring([DeviceActivityName("MidnightReset")])
        
        // Schedule for midnight every day
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 0, minute: 15, second: 0),
            repeats: true
        )
        
        do {
            try center.startMonitoring(
                DeviceActivityName("MidnightReset"),
                during: schedule
            )
            print("✅ Midnight reset monitoring scheduled successfully")
            
            // Also check immediately in case we missed midnight
            checkForPendingMidnightTasks()
        } catch {
            print("❌ Failed to schedule midnight reset: \(error)")
        }
    }
    
    func checkForPendingMidnightTasks() {
        // Check if extension flagged that processing is needed
        if sharedDefaults?.bool(forKey: "needsMidnightProcessing") == true {
            print("📋 Processing pending midnight tasks...")
            
            // Do the tasks that extension couldn't do
            startMonitoringBoundariesForToday()
            deactivateExtensionCodesForYesterday()
            
            // Clear the flag
            sharedDefaults?.set(false, forKey: "needsMidnightProcessing")
        }
        
        // Also check if we missed midnight entirely
        let lastReset = sharedDefaults?.object(forKey: "lastMidnightReset") as? Date ?? .distantPast
        if !Calendar.current.isDateInToday(lastReset) {
            print("⚠️ Missed midnight reset - running full reset now")
            performCompleteMidnightReset()
        }
    }
    
    private func performCompleteMidnightReset() {
        // Unshield apps (this could also be done in extension)
        unshieldApps()
        
        // Start monitoring for today's boundaries
        startMonitoringBoundariesForToday()
        
        // Deactivate yesterday's codes
        deactivateExtensionCodesForYesterday()
        
        // Mark as complete
        sharedDefaults?.set(Date(), forKey: "lastMidnightReset")
        sharedDefaults?.set(false, forKey: "needsMidnightProcessing")
    }
    
    private func unshieldApps() {
        let settingStore = ManagedSettingsStore()
        
        settingStore.shield.applications = nil
        settingStore.shield.webDomains = nil
        settingStore.shield.applicationCategories = nil
        settingStore.shield.webDomainCategories = nil
        
        print("apps unshielded")
    }
    
    private func startMonitoringBoundariesForToday() {
        let activityCenter = DeviceActivityCenter()
        activityCenter.stopMonitoring(activityCenter.activities) // kill all active monitoring seshs
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )
        
        var allBoundaries = screenTime.getBoundariesFromUserDefaults()
        
        let boundariesForToday = allBoundaries.filter({ $0.weekdays.contains(Weekday.today) })
        
        for boundary in boundariesForToday {
            do {
                try activityCenter.startMonitoring(
                    DeviceActivityName(boundary.id.uuidString),
                    during: schedule,
                    events: [DeviceActivityEvent.Name("BoundaryEvent"): DeviceActivityEvent (
                        applications: boundary.appTokens,
                        categories: boundary.categoryTokens,
                        webDomains: boundary.webDomainTokens,
                        threshold: DateComponents(hour: boundary.hours, minute: boundary.minutes)
                    )]
                )
                
                print("Successfully set up monitoring for boundary: \(boundary.givenName)")
            } catch {
                print("Failed to set up monitoring: \(error)")
            }
        }
        
        allBoundaries = allBoundaries.map { currentBoundary in
            print(currentBoundary)
            var updatedBoundary = currentBoundary
            updatedBoundary.isBlocked = false
            return updatedBoundary
        }
        
        self.sharedDefaults!.set(try! JSONEncoder().encode(allBoundaries), forKey: BOUNDARIES_STRING)
        print("new boundaries monitored + saved")
    }
        
    private func deactivateExtensionCodesForYesterday() {
        var extensionCodes = screenTime.getSentExtensionCodes()
        let yesterday = Date.yesterday
        
        extensionCodes = extensionCodes.filter({ areDatesSameDay(date1: yesterday, date2: $0.sentDateTimeUtc) }).map { code in
            var updatedCode = code
            updatedCode.isCodeValid = false
            return updatedCode
        }
        
        sharedDefaults!.set(try! JSONEncoder().encode(extensionCodes), forKey: SENT_EXTENSION_CODES_STRING)
        
        print("extension codes deaticated")
    }
    
    func scheduleTestReset(inMinutes seconds: Int = 120) {
        let center = DeviceActivityCenter()
        
        center.stopMonitoring([DeviceActivityName("MidnightReset")])
        
        let now = Date()
        let calendar = Calendar.current
        let startTime = calendar.date(byAdding: .second, value: seconds, to: now)!
        let endTime = calendar.date(byAdding: .minute, value: 15, to: startTime)!
        
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false
        )
        
        do {
            try center.startMonitoring(
                DeviceActivityName("MidnightReset"),
                during: schedule
            )
            print("🧪 Test reset scheduled for \(startTime)")
        } catch {
            print("❌ Failed to schedule test: \(error)")
        }
    }
}
