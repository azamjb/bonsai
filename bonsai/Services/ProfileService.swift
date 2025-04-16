//
//  ProfileServiceV2.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-03-29.
//

import Foundation

// I want setting to be individual pieces but retrieving to be the entire entity. Taken from databse must be fragmented, but combined into a profile object

enum ProfileKey: String {
    case id = "userProfile_id"
    case name = "userProfile_name"
    case phoneNumber = "userProfile_phoneNumber"
    case hobbies = "userProfile_hobbies"
    case termsAccepted = "userProfile_termsAccepted"
    case accountabilityPartner = "userProfile_accountabilityPartner"
}

protocol ProfileServiceProtocol {
    func saveProfileFields(name: String?, phoneNumber: String?, hobbies: [String]?, termsAccepted: Bool?) async
    func saveAccountabilityPartner(name: String, phoneNumber: String) async
    func fetchUserProfile() -> UserProfile
    func fetchAccountabilityPartner() -> AccountabilityPartner
    func fetchProfileField(key: ProfileKey) -> Any?
}

class ProfileService: ProfileServiceProtocol {
    
    let accountApi = AccountApi()
    private var userProfile = UserProfile()
    private var accountabilityPartner = AccountabilityPartner()

    func fetchUserProfile() -> UserProfile {
        userProfile.name = UserDefaults.standard.string(forKey: ProfileKey.name.rawValue) ?? ""
        userProfile.phoneNumber = UserDefaults.standard.string(forKey: ProfileKey.phoneNumber.rawValue) ?? ""
        userProfile.hobbies = UserDefaults.standard.stringArray(forKey: ProfileKey.hobbies.rawValue) ?? []
        userProfile.termsAccepted = UserDefaults.standard.bool(forKey: ProfileKey.termsAccepted.rawValue)
        return userProfile
    }
    
    func fetchAccountabilityPartner() -> AccountabilityPartner {
        if let data = UserDefaults.standard.data(forKey: ProfileKey.accountabilityPartner.rawValue),
           let partner = try? JSONDecoder().decode(AccountabilityPartner.self, from: data) {
            accountabilityPartner = partner
        }
        return accountabilityPartner
    }

    func fetchProfileField(key: ProfileKey) -> Any? {
        var profileField: Any?
        
        switch(key) {
        case .name, .phoneNumber:
            profileField = UserDefaults.standard.string(forKey: key.rawValue)
            break
        case .hobbies:
            profileField = UserDefaults.standard.stringArray(forKey: key.rawValue)
            break
        case .termsAccepted:
            profileField = UserDefaults.standard.bool(forKey: key.rawValue)
            break
        case .accountabilityPartner:
            profileField = fetchAccountabilityPartner()
            break
        default:
            print("Invalid ProfileKey in fetchProfileField function")
            break
        }
        return profileField
    }

    func saveProfileFields(
        name: String? = nil,
        phoneNumber: String? = nil,
        hobbies: [String]? = nil,
        termsAccepted: Bool? = nil
    ) async {
        var profileHasChanged: Bool = false

        if let name = name {
            UserDefaults.standard.set(name, forKey: ProfileKey.name.rawValue)
            userProfile.name = name
            profileHasChanged = true
        }

        if let phoneNumber = phoneNumber {
            UserDefaults.standard.set(phoneNumber, forKey: ProfileKey.phoneNumber.rawValue)
            userProfile.phoneNumber = phoneNumber
            profileHasChanged = true
        }

        if let hobbies = hobbies {
            UserDefaults.standard.set(hobbies, forKey: ProfileKey.hobbies.rawValue)
            userProfile.hobbies = hobbies
            profileHasChanged = true
        }
        
        if let termsAccepted = termsAccepted {
            UserDefaults.standard.set(termsAccepted, forKey: ProfileKey.termsAccepted.rawValue)
            userProfile.termsAccepted = termsAccepted
            profileHasChanged = true
        }

        if (profileHasChanged) {
            // UNCOMMENT THIS LINE TO TEST THE BACKEND API - CURRENTLY DISABLED
            // await sendProfileToApi()
        }
    }
    
    func saveAccountabilityPartner(name: String, phoneNumber: String) async {
        accountabilityPartner.name = name
        accountabilityPartner.phoneNumber = phoneNumber
        if let encoded = try? JSONEncoder().encode(accountabilityPartner) {
            UserDefaults.standard.set(encoded, forKey: ProfileKey.accountabilityPartner.rawValue)
        }
        
        let idString = UserDefaults.standard.string(forKey: ProfileKey.id.rawValue)
        let request = AddAccountabilityPartner(AccountabilityPartnerName: name, AccountabilityPartnerPhoneNumber: phoneNumber, Id: idString ?? "")

        do {
            try await accountApi.addAccountabilityPartner(request: request)
            print("Successfully added accountability partner")
        } catch {
            print("Failed to add user: \(error.localizedDescription)")
            
            if let error = error as? DecodingError {
                print("Decoding error: \(error)")
            } else {
                print("Raw error: \(error)")
            }
        }
        
    }

    func sendProfileToApi () async {
        let request = RegisterUser(FirstName: userProfile.name ?? "", lastName: userProfile.name ?? "", phoneNumber: userProfile.phoneNumber ?? "")

        do {
            let response: AddUserResponse = try await accountApi.addUser(request: request)
            
            let userId = response.id
            UserDefaults.standard.set(userId, forKey: ProfileKey.id.rawValue)
            print("User added successfully with ID: \(userId)")
            
            userProfile.Id = userId
        } catch {
            print("Failed to add user: \(error)")
        }
    }


}
