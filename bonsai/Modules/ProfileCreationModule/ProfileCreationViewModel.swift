//
//  ProfileCreationViewModel.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import Combine


class ProfileCreationViewModel: ObservableObject {
    @Published var userProfile = UserProfile()
    private let profileService: ProfileServiceProtocol = ProfileService()
    
    func saveBasicInfo(name: String, phoneNumber: String) {
        profileService.saveBasicInfo(name: name, phoneNumber: phoneNumber)
        fetchUserProfile()
    }
    
    func acceptTerms() {
        profileService.markTermsAccepted()
        fetchUserProfile()
    }
    
    func saveHobbies(hobbies: [String]) {
        profileService.saveHobbies(hobbies)
        fetchUserProfile()
    }
    
    func saveAccountabilityPartner(name: String, phoneNumber: String) {
        profileService.saveAccountabilityPartner(name: name, phoneNumber: phoneNumber)
        fetchUserProfile()
    }
    
    func fetchUserProfile() {
        userProfile = profileService.fetchUserProfile()
    }
    
}
