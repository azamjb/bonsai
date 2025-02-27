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
        
        // Remove any non-digit characters
        let cleaned = phoneNumber.filter { "0123456789".contains($0) }
        
        // Ensure there are enough characters
        guard cleaned.count == 10 else { return phoneNumber }
        
        // Format the phone number as (XXX) XXX-XXXX
        let areaCode = cleaned.prefix(3)
        let midSection = cleaned.dropFirst(3).prefix(3)
        let lastSection = cleaned.dropFirst(6).prefix(4)
        
        return "(\(areaCode)) \(midSection)-\(lastSection)"
    }
}

class ProfileViewModel: ObservableObject {
    @Published var userProfile = UserProfile()
    private let profileService = ProfileService()
    
    func fetchUserProfile() {
        userProfile = profileService.fetchUserProfile()
    }
    
    var currentMonth: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            return dateFormatter.string(from: Date())
        }
    
    let phoneNumberFormatter = PhoneNumberFormatter()
}
