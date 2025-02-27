//
//  AppShieldSchedulerService.swift
//  bonsai
//
//  Created by Brayden O on 2025-02-06.
//

import UserNotifications
import BackgroundTasks
import ManagedSettings
import DeviceActivity

class AppShieldSchedulerService {
    static let shared = AppShieldSchedulerService()
    
    let backgroundTaskIdentifier = "com.yourapp.unshieldApps"
    private let appGroupID = "group.com.bonsai"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    func setupDailyUnshield() {
        // Register background task
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: nil
        ) { task in
            self.handleAppUnshield(task: task as! BGProcessingTask)
        }
        
        scheduleNextUnshield()
    }
    
    private func scheduleNextUnshield() {
        // Calculate next midnight
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()),
              let nextMidnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrow) else {
            return
        }
        
        // Schedule background task
        let request = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = nextMidnight
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background task scheduled for next midnight")
        } catch {
            print("Could not schedule app unshield: \(error)")
        }
    }
    
    private func handleAppUnshield(task: BGProcessingTask) {
        let unshieldTask = Task {
            unshieldApps()
            startMonitoringLimitsForToday()
            scheduleNextUnshield()
            task.setTaskCompleted(success: true)
        }
        
        task.expirationHandler = {
            unshieldTask.cancel()
        }
    }
    
    private func unshieldApps() {
        let settingStore = ManagedSettingsStore()
        
        settingStore.shield.applicationCategories = nil
        settingStore.shield.applications = nil
        settingStore.shield.webDomains = nil
        settingStore.shield.webDomainCategories = nil
    }
    
    private func startMonitoringLimitsForToday() {
        let filteredEvents = sharedDefaults!.dictionaryRepresentation()
            .filter { $0.key.hasPrefix(GroupDisplayType.limit.rawValue) }
            .compactMapValues { $0 as? Data }
        
        var events: [ScreenTimeActivityEvent] = []
        
        filteredEvents.forEach { data in
            let activityEvent = try! JSONDecoder().decode(ScreenTimeActivityEvent.self, from: data.value)
            
            if !activityEvent.invisibleLimit && activityEvent.weekdays.contains(Weekday.today) {
                events.append(activityEvent)
            }
        }
        
        let activityCenter = DeviceActivityCenter()
        activityCenter.stopMonitoring(activityCenter.activities) // kill all active monitoring seshs
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0, second: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59, second: 59),
            repeats: true
        )

        let eventId = UUID()
        
        events.forEach { event in
            let activityEvent = ScreenTimeActivityEvent(
                id: eventId,
                givenName: event.givenName,
                appTokens: event.appTokens,
                categoryTokens: event.categoryTokens,
                webDomainTokens: event.webDomainTokens,
                hours: event.hours,
                minutes: event.minutes,
                weekdays: event.weekdays,
                invisibleLimit: false)
            
            let activityName = eventId.uuidString
            
            let encoded = try! JSONEncoder().encode(activityEvent)
            sharedDefaults?.set(encoded, forKey: GroupDisplayType.limit.rawValue + activityName)
            
            try! activityCenter.startMonitoring(
                DeviceActivityName(activityName),
                during: schedule,
                events: [DeviceActivityEvent.Name("LimitEvent"): DeviceActivityEvent (
                    applications: event.appTokens ?? [],
                    categories: event.categoryTokens ?? [],
                    webDomains: event.webDomainTokens ?? [],
                    threshold: DateComponents(hour: event.hours, second: event.minutes)
                )]
            )
        }
    }
}

