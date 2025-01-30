//
//  ProfileServiceExtension.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import Foundation

protocol ProfileServiceProtocol {
    func saveBasicInfo(name: String, phoneNumber: String)
    func saveHobbies(_ hobbies: [String])
    func saveAccountabilityPartner(name: String, phoneNumber: String)
    func markTermsAccepted()
    func fetchUserProfile() -> UserProfile
}

class ProfileService: ProfileServiceProtocol {
    private var userProfile = UserProfile()
    private let userDefaultsKey = "userProfile"
    
    func saveBasicInfo(name: String, phoneNumber: String) {
        userProfile.name = name
        userProfile.phoneNumber = phoneNumber
        saveUserProfile()
    }
    
    func markTermsAccepted() {
        userProfile.termsAccepted = true
        saveUserProfile()
    }
    
    func saveHobbies(_ hobbies: [String]) {
        userProfile.hobbies = hobbies
        saveUserProfile()
    }
    
    func saveAccountabilityPartner(name: String, phoneNumber: String) {
        userProfile.accountabilityPartner = AccountabilityPartner(name: name, phoneNumber: phoneNumber)
        saveUserProfile()
    }
    
    func fetchUserProfile() -> UserProfile {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedProfile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decodedProfile
        }
        return userProfile
    }
    
    private func saveUserProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
}
