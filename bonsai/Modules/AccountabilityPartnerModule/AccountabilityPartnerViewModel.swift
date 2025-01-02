//
//  AccountabilityPartnerViewModel.swift
//  bonsai
//
//  Created by Brayden O on 2025-01-01.
//

import Foundation
import FamilyControls

public class AccountabilityPartnerViewModel: ObservableObject {
    @Published public var phoneNumber: String = ""
    @Published public var code: String = ""
    @Published public var userCode: String = ""
    @Published public var isValidated: Bool = false
    @Published public var isSendInvitePressed: Bool = false
    @Published public var isRequestMoreTimePressed = false
    @Published public var verificationMessage: String? = nil
    @Published public var errorMessage: String = ""
    @Published var isSendingText: Bool = false

    private let userDefaultsKey = "SelectedActivity"
    private let appGroupID = "group.com.bonsai" // Replace with your actual App Group ID
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    public func sendTimeRequest() async {
        isSendInvitePressed = true
        isSendingText = true
        
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
            errorMessage = error.message
        } catch {
            errorMessage = error.localizedDescription
        }

        
        isSendingText = false
    }

    public func generateRandomCode() -> String {
        let randomCode = Int.random(in: 100_000...999_999)
        return String(randomCode)
    }
}
