//
//  ProfileViewModel.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import Foundation
import Combine


class PhoneNumberFormatter: Formatter {
    override func string(for obj: Any?) -> String? {
        guard let phoneNumber = obj as? String else { return nil }

        // Remove non-digit characters, but keep '+' if it's at the start
        var cleaned = phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasPlus = cleaned.hasPrefix("+")
        cleaned = cleaned.filter { "0123456789".contains($0) }

        // If the number has a +1 country code, format accordingly
        if cleaned.count == 11 && cleaned.hasPrefix("1") {
            let areaCode = cleaned.dropFirst(1).prefix(3)
            let mid = cleaned.dropFirst(4).prefix(3)
            let last = cleaned.suffix(4)
            return "+1 (\(areaCode)) \(mid)-\(last)"
        }

        // If the number has exactly 10 digits
        if cleaned.count == 10 {
            let areaCode = cleaned.prefix(3)
            let mid = cleaned.dropFirst(3).prefix(3)
            let last = cleaned.suffix(4)
            return "(\(areaCode)) \(mid)-\(last)"
        }

        // Fallback
        return phoneNumber
    }
}


class ProfileViewModel: ObservableObject {

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: BONSAI_GROUP_NAME)
    }

    @Published var userProfile = UserProfile()
    @Published var accountabilityPartner = AccountabilityPartner()
    private let screenTime = ScreenTimeService()
    private let profileService = ProfileService()

    init() {
        fetchUserProfile()
        fetchAccountabilityPartner()
    }
    
    func fetchUserProfile() {
        userProfile = profileService.fetchUserProfile()
    }

    func fetchAccountabilityPartner() {
        accountabilityPartner = profileService.fetchAccountabilityPartner()
    }



    var currentMonth: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        return dateFormatter.string(from: Date())
    }
    
    let phoneNumberFormatter = PhoneNumberFormatter()

    func saveProfileFields(name: String?, phoneNumber: String?, hobbies: [String]?, termsAccepted: Bool?) async {
        await profileService.saveProfileFields(name: name, phoneNumber: phoneNumber, hobbies: hobbies, termsAccepted: termsAccepted)
        fetchUserProfile()
    }
    
    public func getCurrentStreakDays() -> Int {
        let sortedExtensions = screenTime.getDailyBoundaryExtensionsModels().sorted(by: { $0.extendedDateTimeUtc < $1.extendedDateTimeUtc })
        
        if sortedExtensions.isEmpty {
            return 0
        }
        
        let mostRecentExtension = sortedExtensions.last!
        
        let secondsDifference = Date().timeIntervalSinceReferenceDate - mostRecentExtension.extendedDateTimeUtc.timeIntervalSinceReferenceDate
        
        // convert seconds to days and return int
        return Int(secondsDifference / (60 * 60 * 24))
    }
    
    public func getLongestStreakDays() -> Int {
        let extensions = screenTime.getDailyBoundaryExtensionsModels().sorted(by: { $0.extendedDateTimeUtc < $1.extendedDateTimeUtc })
        
        if extensions.isEmpty {
            return 0
        }
        
        var longestStreak = 0
        
        // loop through extensions to find the longest gap between them
        for i in 0..<(extensions.count - 1) {
            let currentExtension = extensions[i]
            let nextExtension = extensions[i + 1]
            
            let secondsDifference = nextExtension.extendedDateTimeUtc.timeIntervalSinceReferenceDate - currentExtension.extendedDateTimeUtc.timeIntervalSinceReferenceDate
            let daysDifference = Int(secondsDifference / (60 * 60 * 24))
            
            if daysDifference > longestStreak {
                longestStreak = daysDifference
            }
        }
        
        // check the streak from the last extension to today
        let lastExtension = extensions.last!
        let secondsSinceLastExtension = Date().timeIntervalSinceReferenceDate - lastExtension.extendedDateTimeUtc.timeIntervalSinceReferenceDate
        let daysSinceLastExtension = Int(secondsSinceLastExtension / (60 * 60 * 24))
        
        if daysSinceLastExtension > longestStreak {
            longestStreak = daysSinceLastExtension
        }
        
        return longestStreak
    }
    
    public func getTotalDaysWithoutExtension() -> Int {
        if let signUpDateData = sharedDefaults!.data(forKey: SIGN_UP_DATE_STRING) {
            let signUpDate = try! JSONDecoder().decode(Date.self, from: signUpDateData)
            
            // get all extensions after the start date
            let allExtensions = screenTime.getDailyBoundaryExtensionsModels()
            let extensionsAfterStartDate = allExtensions.filter {
                $0.extendedDateTimeUtc >= signUpDate
            }
            
            // calculate total days from start date to now
            let totalSeconds = Date().timeIntervalSinceReferenceDate - signUpDate.timeIntervalSinceReferenceDate
            let totalDays = Int(totalSeconds / (60 * 60 * 24))
            
            // count days with extensions (we need to count each day only once)
            var daysWithExtensionsSet = Set<String>()
            let calendar = Calendar.current
            
            for extensionModel in extensionsAfterStartDate {
                // get the date components to identify the day (ignoring time)
                let components = calendar.dateComponents([.year, .month, .day], from: extensionModel.extendedDateTimeUtc)
                // create a string key for the day
                if let year = components.year, let month = components.month, let day = components.day {
                    let dayKey = "\(year)-\(month)-\(day)"
                    daysWithExtensionsSet.insert(dayKey)
                }
            }
            
            let daysWithExtensions = daysWithExtensionsSet.count
            
            return min(0, totalDays - daysWithExtensions)
        } else {
            sharedDefaults!.set(try! JSONEncoder().encode(Date()), forKey: SIGN_UP_DATE_STRING)
            return 0
        }
    }
    
    public func getExtensionRequestsCount() -> Int {
        return screenTime.getSentExtensionCodes().count 
    }
}
