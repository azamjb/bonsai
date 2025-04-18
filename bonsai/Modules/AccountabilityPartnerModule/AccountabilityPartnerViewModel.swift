//
//  AccountabilityPartnerViewModel.swift
//  bonsai
//
//  Created by Brayden O on 2025-01-01.
//

import Foundation
import FamilyControls
import ManagedSettings

@MainActor public class AccountabilityPartnerViewModel: ObservableObject {
    
    @Published public var phoneNumber: String = ""
    @Published public var code: String = ""
    @Published public var note: String = ""
    @Published public var userCode: String = ""
    @Published public var isValidated: Bool = false
    @Published public var isSendInvitePressed: Bool = false
    @Published public var isRequestMoreTimePressed = false
    @Published public var verificationMessage: String? = nil
    @Published public var inviteErrorMessage: String = ""
    @Published public var timeRequestErrorMessage: String = ""
    @Published public var appTokenToExtend: ApplicationToken? = nil
    @Published public var categoryTokenToExtend: ActivityCategoryToken? = nil
    @Published public var webDomainTokenToExtend: WebDomainToken? = nil

    @Published public var isSendingInvite: Bool = false
    @Published public var isSendingTimeRequest: Bool = false
    @Published public var isRemovingAccountabilityPartner: Bool = false
    
    
    

    private let userDefaultsKey = "SelectedActivity"
    private let appGroupID = "group.com.bonsai" 
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    public func sendInvite(phoneNumber: String, userName: String, accountabilityPartnerName: String) async {
        isSendInvitePressed = true
        isSendingInvite = true
        
        let smsApi = SMSApi()
        code = generateRandomCode()
        
        do {
            try await smsApi.invite(
                request: SMSInvite(
                    number: phoneNumber,
                    username: userName,
                    accountabilityPartnerName: accountabilityPartnerName,
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
    
    public func removeAccountabilityPartner( phoneNumber: String, userName: String, accountabilityPartnerName: String) async {
       
        
        isRemovingAccountabilityPartner = true
        
        let smsApi = SMSApi()
        do {
            try await smsApi.removalNotif(
                request: SMSInvite(
                    number: phoneNumber,
                    username: userName,
                    accountabilityPartnerName: accountabilityPartnerName,
                    code: ""
                )
            )
            UserDefaults.standard.removeObject(forKey: "AccountabilityPartnerNumber")
            isValidated = false
            isSendInvitePressed = false
            
        } catch let error as StringError {
            inviteErrorMessage = error.message
        } catch {
            inviteErrorMessage = error.localizedDescription
        }
        
        isRemovingAccountabilityPartner =  false
    }
    
    public func sendTimeRequest(phoneNumber: String, userName: String, accountabilityPartnerName: String, note: String) async {
        let smsApi = SMSApi()
        isSendingTimeRequest = true
        code = generateRandomCode()
        
        print(phoneNumber, userName, accountabilityPartnerName, note)
        do {
            try await smsApi.timeRequest(
                request: SMSRequest(
                    number: phoneNumber,
                    username: userName,
                    accountabilityPartnerName: accountabilityPartnerName,
                    note: note,
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
    
    public func validateVerificationCode( Pin: String) -> Bool { // validate if the code entered by the user is correct or incorrect
        print("code: " + (UserDefaults.standard.string(forKey: LocalStorageKeys.timeExtensionRequestCode) ?? ""))
        print("pin: " + Pin)
        if Pin == (UserDefaults.standard.string(forKey: LocalStorageKeys.timeExtensionRequestCode) ?? "") {
            return true;
        } else {
            return false;
        }
    }

    public func generateRandomCode() -> String {
        let randomCode = Int.random(in: 100_000...999_999)
        return String(randomCode)
    }
}
