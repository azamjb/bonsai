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
    private let profileService: ProfileServiceProtocol = ProfileService()
    
    func saveBasicInfo(name: String, phoneNumber: String) async {
        
        await profileService.saveBasicInfo(name: name, phoneNumber: phoneNumber)
        
        initRemainingBoundaryEdits()
        initDailyBoundaryExtensions()
        
        fetchUserProfile()
    }
    
    func acceptTerms() {
        profileService.markTermsAccepted()
        fetchUserProfile()
    }
    
    func saveHobbies(hobbies: [String])async {
        profileService.saveHobbies(hobbies)
        fetchUserProfile()
    }
    
    func saveAccountabilityPartner(name: String, phoneNumber: String) async {
        await profileService.saveAccountabilityPartner(name: name, phoneNumber: phoneNumber)
        fetchUserProfile()
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
}
