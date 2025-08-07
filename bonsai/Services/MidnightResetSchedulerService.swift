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
        
        center.stopMonitoring([DeviceActivityName(MIDNIGHT_RESET_STRING)])
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 0, minute: 15, second: 0), // 15 minutes is the minimum interval. will throw error otherwise.
            repeats: true
        )
        
        do {
            try center.startMonitoring(
                DeviceActivityName(MIDNIGHT_RESET_STRING),
                during: schedule
            )
            print("✅ Midnight reset monitoring scheduled successfully")
        } catch {
            print("❌ Failed to schedule midnight reset: \(error)")
        }
    }
    
    
    // MARK: - For testing locally. Uncomment this call in root app view and comment out the regular 'setupMidnightReset' for testing.
    func setupTESTReset(inMinutes minutes: Int = 1) {
        let center = DeviceActivityCenter()
        
        center.stopMonitoring([DeviceActivityName(MIDNIGHT_RESET_STRING)])
        
        let now = Date()
        let calendar = Calendar.current
        let startTime = calendar.date(byAdding: .minute, value: minutes, to: now)!
        let endTime = calendar.date(byAdding: .minute, value: 15, to: startTime)! // 15 minutes is the minimum interval. will throw error otherwise.
        
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)
        
        let schedule = DeviceActivitySchedule(
            intervalStart: startComponents,
            intervalEnd: endComponents,
            repeats: false
        )
        
        do {
            try center.startMonitoring(
                DeviceActivityName(MIDNIGHT_RESET_STRING),
                during: schedule
            )
            print("🧪 Test reset scheduled for \(startTime)")
        } catch {
            print("❌ Failed to schedule test: \(error)")
        }
    }
}
