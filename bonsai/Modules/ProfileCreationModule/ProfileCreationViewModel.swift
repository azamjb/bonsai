//
//  ProfileCreationViewModel.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import Combine


class ProfileCreationViewModel: ObservableObject {
    
    @Published var userProfile = UserProfile()
    @Published var accountabilityPartner = AccountabilityPartner()
    private let profileService: ProfileServiceProtocol = ProfileService()
    
    func saveBasicInfo(name: String, phoneNumber: String) async {
        
        await profileService.saveBasicInfo(name: name, phoneNumber: phoneNumber)
    func saveProfileFields(name: String?, phoneNumber: String?, hobbies: [String]?, termsAccepted: Bool?) async {
        await profileService.saveProfileFields(name: name, phoneNumber: phoneNumber, hobbies: hobbies, termsAccepted: termsAccepted)
        fetchUserProfile()
    }
    
    func saveAccountabilityPartner(name: String, phoneNumber: String) async {
        await profileService.saveAccountabilityPartner(name: name, phoneNumber: phoneNumber)
        fetchUserProfile()
        fetchAccountabilityPartner()
    }
    
    func fetchUserProfile() {
        userProfile = profileService.fetchUserProfile()
    }
    
    func fetchAccountabilityPartner() {
        accountabilityPartner = profileService.fetchAccountabilityPartner()
    }
    
    
    
}
