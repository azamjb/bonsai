import UserNotifications
import BackgroundTasks
import ManagedSettings
import DeviceActivity

class NightlySchedulerService {
    static let shared = NightlySchedulerService()
    let screenTime = ScreenTimeService()
    
    let backgroundTaskIdentifier = "com.bonsai.unshieldApps"
    private let appGroupID = "group.com.bonsai"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    func setupDailyUnshield() {
        // Register background task with a specific queue
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: DispatchQueue.global(qos: .background)
        ) { task in
            self.handleAppUnshield(task: task as! BGProcessingTask)
        }
        
        // Schedule immediately to ensure we have one pending
        scheduleNextUnshield()
        
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            print("After scheduling - Pending tasks: \(requests.map { $0.identifier })")
            for request in requests {
                print("Task \(request.identifier) scheduled for \(request.earliestBeginDate?.description ?? "nil")")
            }
        }
    }
    
    private func scheduleNextUnshield() {
        // Calculate next midnight
        let calendar = Calendar.current
        let midnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: Date())!)!
        
        // First cancel any existing requests to avoid duplicates
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundTaskIdentifier)
        
        // Schedule background task
        let request = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = midnight
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
            
            // Save the scheduled date
            sharedDefaults!.set(midnight, forKey: LAST_SCHEDULED_MIDNIGHT_UNSHIELD_STRING)
            
            // Request notification permissions if needed
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
            
            sendNotification(title: "Unshield scheduled for midnight", body: "\(midnight)")
        } catch {
            print("Could not schedule app unshield: \(error)")
        }
    }
    
    private func handleAppUnshield(task: BGProcessingTask) {
        print("got unshiled app request")

        self.unshieldApps()
        self.startMonitoringBoundariesForToday()
        self.deactivateExtensionCodesForYesterday()

        // Log successful execution
        self.sharedDefaults!.set(Date(), forKey: LAST_SUCCESSFUL_UNSHIELD_STRING)
        
        self.scheduleNextUnshield()

        task.setTaskCompleted(success: true)
    }
    
    private func unshieldApps() {
        DispatchQueue.main.sync {
            let settingStore = ManagedSettingsStore()
            
            settingStore.shield.applications = nil
            settingStore.shield.webDomains = nil
            settingStore.shield.applicationCategories = nil
            settingStore.shield.webDomainCategories = nil
        }
        
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
        
        print(allBoundaries)
        
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
}
