//
//  WeeklySchedulerService.swift
//  bonsai
//
//  Created by Brayden O on 2025-04-18.
//

import UserNotifications
import BackgroundTasks
import ManagedSettings
import DeviceActivity

class WeeklySchedulerService {
    static let shared = WeeklySchedulerService()
    
    let backgroundTaskIdentifier = "com.bonsai.weeklyOperation"
    private let appGroupID = "group.com.bonsai"
    private let lastScheduledKey = "lastScheduledWeeklyOperationDate"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    func setupWeeklySchedule() {
        // Register background task with a specific queue
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: backgroundTaskIdentifier,
            using: DispatchQueue.global(qos: .background)
        ) { task in
            self.handleWeeklyOperation(task: task as! BGProcessingTask)
        }
        
        // Schedule immediately to ensure we have one pending
        scheduleNextMondayOperation()
    }
    
    private func scheduleNextMondayOperation() {
        // Calculate next Monday at midnight
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        
        // In Calendar, 1 = Sunday, 2 = Monday, etc.
        // Calculate days until next Monday (if today is Monday, it will be 7 days later)
        let daysUntilNextMonday = weekday == 2 ? 7 : (9 - weekday) % 7
        
        guard let nextMonday = calendar.date(byAdding: .day, value: daysUntilNextMonday, to: today),
              let nextMondayMidnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: nextMonday) else {
            return
        }
        
        // Check if we've already scheduled for this Monday
        if let lastScheduled = sharedDefaults?.object(forKey: lastScheduledKey) as? Date,
           calendar.isDate(lastScheduled, inSameDayAs: nextMondayMidnight) {
            return
        }
        
        // First cancel any existing requests to avoid duplicates
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: backgroundTaskIdentifier)
        
        // Schedule background task
        let request = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        request.earliestBeginDate = nextMondayMidnight
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
            
            // Save the scheduled date
            sharedDefaults?.set(nextMondayMidnight, forKey: lastScheduledKey)
            
            // Request notification permissions if needed
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
            
            // Schedule local notification for debug purposes
            scheduleDebugNotification(for: nextMondayMidnight, message: "Weekly operation scheduled for Monday")
        } catch {
            print("Could not schedule weekly operation: \(error)")
        }
    }
    
    private func handleWeeklyOperation(task: BGProcessingTask) {
        let taskGroup = DispatchGroup()
        
        var success = false
        
        taskGroup.enter()
        DispatchQueue.global(qos: .userInitiated).async {
            let encoded = try! JSONEncoder().encode(DailyBoundaryExtensionsModel())
            self.sharedDefaults?.set(encoded, forKey: DAILY_BOUNDARY_EXTENSIONS_STRING)
            
            self.sharedDefaults?.set(2, forKey: REMAINING_BOUNDARY_EXTENSIONS_STRING)

            self.scheduleDebugNotification(for: Date(), message: "Weekly Monday operation executed successfully")
            
            success = true
            taskGroup.leave()
        }
        
        // Set up expiration handler
        task.expirationHandler = {
            self.scheduleDebugNotification(for: Date(), message: "Weekly operation task expired")
            taskGroup.leave()
        }
        
        // Wait for task to complete
        taskGroup.notify(queue: .main) {
            // Schedule the next task regardless of success
            self.scheduleNextMondayOperation()
            task.setTaskCompleted(success: success)
            
            // Request background processing time one more time in case there were issues
            let request = BGAppRefreshTaskRequest(identifier: self.backgroundTaskIdentifier)
            request.earliestBeginDate = Date(timeIntervalSinceNow: 3600) // 1 hour later as backup
            try? BGTaskScheduler.shared.submit(request)
        }
    }
    
    private func scheduleDebugNotification(for date: Date, message: String) {
        let content = UNMutableNotificationContent()
        content.title = "Weekly Scheduler Debug"
        content.body = message
        content.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
