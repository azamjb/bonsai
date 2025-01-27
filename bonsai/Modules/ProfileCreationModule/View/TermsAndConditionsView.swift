//
//  TermsAndConditionsView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import SwiftUI

struct TermsAndConditionsView: View {
    @ObservedObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("Please accept our Terms and Conditions")
                Button("Test") {
                    testProfileService()
                }
                NavigationLink(destination: ProfileCreation2View()) {
                    Text("Accept")
                        .foregroundColor(.white) // White text and icon
                        .padding() // Padding inside the button
                        .frame(maxWidth: .infinity) // Full-width button
                        .background(Color.black) // Black background
                        .cornerRadius(12) // Rounded corners
                }
            }
        }
        
    }
    func testProfileService() {
        let profileService = ProfileService()
        
        // Save profile data
        profileService.saveBasicInfo(name: "John Doe", phoneNumber: "1234567890")
        profileService.markTermsAccepted()
        profileService.saveHobbies(["Reading", "Gaming", "Traveling"])
        profileService.saveAccountabilityPartner(name: "Jane Smith", phoneNumber: "0987654321")
        
        // Fetch and print the user profile
        let userProfile = profileService.fetchUserProfile()
        print(userProfile.name)  // Output: John Doe
        print(userProfile.hobbies)  // Output: ["Reading", "Gaming", "Traveling"]
        print(userProfile.accountabilityPartner?.name ?? "No Partner")  // Output: Jane Smith
    }
    
}

#Preview {
    TermsAndConditionsView()
}
