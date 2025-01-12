//
//  AccountabilityPartnerViewModel.swift
//  bonsai
//
//  Created by Brayden O on 2025-01-01.
//

import Foundation
import FamilyControls

@MainActor public class AccountabilityPartnerViewModel: ObservableObject {
    @Published public var phoneNumber: String = ""
    @Published public var code: String = ""
    @Published public var userCode: String = ""
    @Published public var isValidated: Bool = false
    @Published public var isSendInvitePressed: Bool = false
    @Published public var isRequestMoreTimePressed = false
    @Published public var verificationMessage: String? = nil
    @Published public var inviteErrorMessage: String = ""
    @Published public var timeRequestErrorMessage: String = ""

    @Published public var isSendingInvite: Bool = false
    @Published public var isSendingTimeRequest: Bool = false
    @Published public var isRemovingAccountabilityPartner: Bool = false

    private let userDefaultsKey = "SelectedActivity"
    private let appGroupID = "group.com.bonsai" // Replace with your actual App Group ID
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    public func sendInvite() async {
        
        isSendInvitePressed = true
        isSendingInvite = true
        
        let smsApi = SMSApi()
        code = generateRandomCode()
        
        do {
            try await smsApi.invite(
                request: SMSRequest(
                    number: phoneNumber,
                    username: "Azam",
                    accountabilityPartnerName: "Bob",
                    code: code
                )
            )
        } catch let error as StringError {
            inviteErrorMessage = error.message
        } catch {
            inviteErrorMessage = error.localizedDescription
        }

        isSendingInvite = false
    }
    
    
    public func removeAccountabilityPartner() async {
        
        isRemovingAccountabilityPartner = true
        
        let smsApi = SMSApi()
        do {
            try await smsApi.removalNotif(
                request: SMSRequest(
                    number: phoneNumber,
                    username: "Azam",
                    accountabilityPartnerName: "Bob",
                    code: ""
                )
            )
            UserDefaults.standard.removeObject(forKey: "AccountabilityPartnerNumber")
            isValidated = false
            isSendInvitePressed = false
            phoneNumber = ""
            
        } catch let error as StringError {
            inviteErrorMessage = error.message
        } catch {
            inviteErrorMessage = error.localizedDescription
        }
        
        isRemovingAccountabilityPartner =  false
    }
    
    public func sendTimeRequest() async {
        let smsApi = SMSApi()
        isSendingTimeRequest = true
        code = generateRandomCode()
        
        do {
            try await smsApi.timeRequest(
                request: SMSRequest(
                    number: phoneNumber,
                    username: "Azam",
                    accountabilityPartnerName: "Bob",
                    code: code
                )
            )
            UserDefaults.standard.set(code, forKey: LocalStorageKeys.timeExtensionRequestCode) // set code in local
        } catch let error as StringError {
            timeRequestErrorMessage = error.message
        } catch {
            timeRequestErrorMessage = error.localizedDescription
        }
        
        isSendingTimeRequest = false
    }
    
    public func validateVerificationCode() {
        if userCode == code {
            isValidated = true
            verificationMessage = "Verification Successful!"
            UserDefaults.standard.set(phoneNumber, forKey: LocalStorageKeys.AccountabilityPartnerNumber) // store number when verified - accounability partner is set
            userCode = ""
        } else {
            isValidated = false
            verificationMessage = "Invalid Code. Please try again."
        }
    }

    public func generateRandomCode() -> String {
        let randomCode = Int.random(in: 100_000...999_999)
        return String(randomCode)
    }
}
