//
//  ProfileCreationViewModel.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import Combine
import Foundation


class ProfileCreationViewModel: ObservableObject {
    private let appGroupID = "group.com.bonsai"

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    @Published var userProfile = UserProfile()
    @Published var accountabilityPartner = AccountabilityPartner()
    private let profileService: ProfileServiceProtocol = ProfileService()
    

    func saveProfileFields(name: String?, phoneNumber: String?, hobbies: [String]?, termsAccepted: Bool?) async {
        await profileService.saveProfileFields(name: name, phoneNumber: phoneNumber, hobbies: hobbies, termsAccepted: termsAccepted)
        
        initRemainingBoundaryEdits()
        initDailyBoundaryExtensions()
        
        fetchUserProfile()
    }
    
    func saveAccountabilityPartner(name: String, phoneNumber: String) async {
        await profileService.saveAccountabilityPartner(name: name, phoneNumber: phoneNumber)
        fetchUserProfile()
        fetchAccountabilityPartner()
    }
    
    func initRemainingBoundaryEdits() {
        sharedDefaults?.set(2, forKey: REMAINING_BOUNDARY_EXTENSIONS_STRING)
    }
    
    func initDailyBoundaryExtensions() {
        sharedDefaults?.set(try! JSONEncoder().encode(DailyBoundaryExtensionsModel()), forKey: DAILY_BOUNDARY_EXTENSIONS_STRING)
    }


    func fetchUserProfile() {
        userProfile = profileService.fetchUserProfile()
    }
    
    func fetchAccountabilityPartner() {
        accountabilityPartner = profileService.fetchAccountabilityPartner()
    }
}
