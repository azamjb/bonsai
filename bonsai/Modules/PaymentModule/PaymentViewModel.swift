//
//  PaymentViewModel.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-05-19.
//

import Foundation
import Combine

class PaymentViewModel: ObservableObject {
    private var selectedTokenBundle: PurchaseOption = .one
    private let tokenService: TokenServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let userId: String

    
    init() {
        let tokenStorage = TokenStorageService(database: LocalDatabase.shared.databaseWriter)
        self.tokenService = TokenService(storage: tokenStorage)
        self.profileService = ProfileService()
        userId = profileService.fetchUserProfile().Id ?? "Unknown User"
    }
    
    func purchaseSelectedTokenBundle(selectedOption: PurchaseOption) async throws{
        selectedTokenBundle = selectedOption
        // TODO: Need to implement a payment service and resulting request which should handle the payment.
        // if payment successful then use the token service to add the tokens. if unsuccessful for whatever reason, log the attemp as unsuccessful and pass the error to user
        // TODO: DISPLAY FAILED PAYMENT ATTEMPT
        // for now, transactionId = UUID()
        
        let temporaryTransactionId = UUID().uuidString
        let numberOfTokensToPurchase = selectedTokenBundle.amount
        do {
            try await tokenService.purchaseTokens(forUserWithId: userId, amount: numberOfTokensToPurchase, transactionId: temporaryTransactionId)
        } catch {
            // TODO: DISPLAY FAILED TOKEN ADDITION ERROR
        }
    }
}
