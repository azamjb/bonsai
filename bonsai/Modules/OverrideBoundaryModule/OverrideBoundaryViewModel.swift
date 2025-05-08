//
//  OverrideBoundaryViewModel.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-05-03.
//

import Combine
import Foundation

class OverrideBoundaryViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var tokenTransactions: [TokenTransaction] = []
    @Published var tokenBalance: Int = 0
    private let tokenService: TokenServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let userId: String
    
    init() {
        let tokenStorage = TokenStorageService(database: LocalDatabase.shared.databaseWriter)
        self.tokenService = TokenService(storage: tokenStorage)
        self.profileService = ProfileService()
        userId = profileService.fetchUserProfile().Id ?? "Unknown User"
    }
    
    func loadData() { 
        Task {
            await loadTokenBalance()
            await loadTokenTransactions()
        }
    }
    
    func loadTokenTransactions() async {
        do {
            // Fetch the transactions
            let transactions = try await tokenService.fetchAllTokenTransactions(forUserWithId: userId)
            
            // Update on main thread since we're changing @Published properties
            DispatchQueue.main.async {
                self.tokenTransactions = transactions
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to fetch transactions: \(error.localizedDescription)"
            }
        }
    }
    
    func grantTokens(_ amount: Int) async {
        do {
            try await tokenService.grantTokens(forUserWithId: userId, amount: amount)
            await loadTokenBalance()
            await loadTokenTransactions()
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to grant tokens: \(error.localizedDescription)"
            }
        }
    }
    
    func loadTokenBalance() async {
        do {
            // Fetch the transactions
            let balance = try await tokenService.fetchTokenBalance(forUserWithId: userId)
            
            // Update on main thread since we're changing @Published properties
            // (this should be propogated to fix the other thread issues we have)
            DispatchQueue.main.async {
                self.tokenBalance = balance
                self.errorMessage = nil
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to fetch token balance: \(error.localizedDescription)"
            }
        }
    }

    var currentDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        // DateFormatter uses the user's locale by default
        return dateFormatter.string(from: Date())
    }
}
