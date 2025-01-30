//
//  ProfileViewModel.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var userProfile = UserProfile()
    private let profileService = ProfileService()
    
    func fetchUserProfile() {
        userProfile = profileService.fetchUserProfile()
    }
}
