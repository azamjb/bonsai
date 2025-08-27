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
    private var screenTime = ScreenTimeService()
    
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
    
    private let sentExtensionCodeService = SentExtensionCodeService(storage: SentExtensionCodeStorageService(database: LocalDatabase.shared.databaseWriter))

    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: BONSAI_GROUP_NAME)
    }

    public func sendInvite(phoneNumber: String, userName: String, accountabilityPartnerName: String) async {
        isSendInvitePressed = true
        isSendingInvite = true
        
        let smsApi = SMSApi()
        code = generateRandomCode()
        UserDefaults.standard.set(code, forKey: ACCOUNTABILITY_PARTNER_INVITE_CODE_STRING)
        
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
    
    public func sendTimeRequest(phoneNumber: String, userName: String, accountabilityPartnerName: String, note: String, boundaries: [Boundary]) async {
        let smsApi = SMSApi()
        isSendingTimeRequest = true
        code = generateRandomCode()
        
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
            
            boundaries.forEach { boundary in
                screenTime.addActiveExtensionCode(boundaryId: boundary.id, code: code)
            }
        } catch let error as StringError {
            timeRequestErrorMessage = error.message
        } catch {
            timeRequestErrorMessage = error.localizedDescription
        }
        
        isSendingTimeRequest = false
    }
    
    public func validateVerificationCode(pin: String) -> Bool {
        let boundaryIdsForCodeIfValid = sentExtensionCodeService.getBoundaryIdsForActiveCode(code: pin)
        
        if boundaryIdsForCodeIfValid.isEmpty {
            return false
        } else {
            boundaryIdsForCodeIfValid.forEach { id in
                screenTime.extendBlockedBoundary(boundaryId: id)
                screenTime.setGroupDisplays()
            }
            
            return true
        }
    }

    public func generateRandomCode() -> String {
        let randomCode = Int.random(in: 100_000...999_999)
        return String(randomCode)
    }
}
