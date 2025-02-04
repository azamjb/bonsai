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
    func saveAccountabilityPartner(name: String, phoneNumber: String) async
    func markTermsAccepted()
    func fetchUserProfile() -> UserProfile
}

class ProfileService: ProfileServiceProtocol {
    
    let accountApi = AccountApi()
    private var userProfile = UserProfile()
    private let userDefaultsKey = "userProfile"
    
    func saveBasicInfo(name: String, phoneNumber: String) {
        
        userProfile.name = name
        userProfile.phoneNumber = phoneNumber
        Task {
            await saveUserProfile()
        }
    }
    
    func markTermsAccepted() {
        userProfile.termsAccepted = true
        Task {
            await saveUserProfile()
        }
    }
    
    func saveHobbies(_ hobbies: [String]) {
        userProfile.hobbies = hobbies
        Task {
            await saveUserProfile()
        }
    }
    
    
    func saveAccountabilityPartner(name: String, phoneNumber: String) async {
        
        userProfile.accountabilityPartner = AccountabilityPartner(name: name, phoneNumber: phoneNumber)

        let idString = userProfile.Id?.lowercased()
        
        print(name)
        print(phoneNumber)
        print(idString)
        let request = AddAccountabilityPartner(AccountabilityPartnerName: name, AccountabilityPartnerPhoneNumber: phoneNumber, Id: idString ?? "")

        do {
            try await accountApi.addAccountabilityParnter(request: request)
            print("Successfully added accountability partner")
        } catch {
            print("Failed to add user: \(error.localizedDescription)")
            
            if let error = error as? DecodingError {
                print("Decoding error: \(error)")
            } else {
                print("Raw error: \(error)")
            }
        }

        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }


    
    func fetchUserProfile() -> UserProfile {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedProfile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decodedProfile
        }
        
        return userProfile
    }
    
    private func saveUserProfile() async {
        let request = RegisterUser(FirstName: userProfile.name, lastName: userProfile.name, phoneNumber: userProfile.phoneNumber)
        
        do {
            let response: AddUserResponse = try await accountApi.addUser(request: request)
            
            let userId = response.id
            print("User added successfully with ID: \(userId)")
            
            userProfile.Id = userId
        } catch {
            print("Failed to add user: \(error)")
        }
        
        // Encode and save the user profile data
        if let encoded = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }


}
