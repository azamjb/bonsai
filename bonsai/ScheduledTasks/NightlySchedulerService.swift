import UserNotifications
import BackgroundTasks
import ManagedSettings
import DeviceActivity

class NightlySchedulerService {
    static let shared = NightlySchedulerService ()
    let screenTime = ScreenTimeService()
    
    let backgroundTaskIdentifier = "com.bonsai.unshieldApps"
    private let appGroupID = "group.com.bonsai"
    private let lastScheduledKey = "lastScheduledUnshieldDate"

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
    }
    
    private func scheduleNextUnshield() {
        // Calculate next midnight
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()),
              let nextMidnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) else {
            return
        }
        
        // Check if we've already scheduled for this midnight
        if let lastScheduled = sharedDefaults?.object(forKey: lastScheduledKey) as? Date,
           calendar.isDate(lastScheduled, inSameDayAs: nextMidnight) {
            return
        }
        
        // First cancel any existing requests to avoid duplicates
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundTaskIdentifier)
        
        // Schedule background task
        let request = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = nextMidnight
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
            
            // Save the scheduled date
            sharedDefaults?.set(nextMidnight, forKey: lastScheduledKey)
            
            // Request notification permissions if needed
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        } catch {
            print("Could not schedule app unshield: \(error)")
        }
    }
    
    private func handleAppUnshield(task: BGProcessingTask) {
        // Create a task group to handle all operations
        let taskGroup = DispatchGroup()
        
        // Track success
        var success = false
        
        taskGroup.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            self.unshieldApps()
            self.startMonitoringBoundariesForToday()
            self.deactivateExtensionCodesForYesterday()
            
            // Log successful execution
            self.sharedDefaults!.set(Date(), forKey: LAST_SUCCESSFUL_UNSHIELD_STRING)
            
            success = true
            taskGroup.leave()
        }
        
        // Set up expiration handler
        task.expirationHandler = {
            self.scheduleDebugNotification(for: Date(), message: "Unshield task expired")
            taskGroup.leave() // Ensure we don't deadlock
        }
        
        // Wait for task to complete
        taskGroup.notify(queue: .main) {
            // Schedule the next task regardless of success
            self.scheduleNextUnshield()
            task.setTaskCompleted(success: success)
            
            // Request background processing time one more time in case there were issues
            let request = BGAppRefreshTaskRequest(identifier: self.backgroundTaskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 3600) // 1 hour later as backup
            try? BGTaskScheduler.shared.submit(request)
        }
    }
    
    private func unshieldApps() {
        let settingStore = ManagedSettingsStore()
        
        settingStore.shield.applicationCategories = nil
        settingStore.shield.applications = nil
        settingStore.shield.webDomains = nil
        settingStore.shield.webDomainCategories = nil
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
            if let boundary = boundariesForToday.first(where: { $0.id == currentBoundary.id }) {
                return boundary
            } else {
                return currentBoundary
            }
        }
        
        self.sharedDefaults!.set(try! JSONEncoder().encode(allBoundaries), forKey: BOUNDARIES_STRING)
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
    }
    
    private func scheduleDebugNotification(for date: Date, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "AppShield Debug"
        content.body = message
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
