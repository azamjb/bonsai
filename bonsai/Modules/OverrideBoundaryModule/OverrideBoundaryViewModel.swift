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
    
    func grantTokens(_ amount: Int) async -> TokenResponseCode {
        var result: TokenResponseCode
        do {
            result = try await tokenService.grantTokens(forUserWithId: userId, amount: amount)
            if result == .success {
                loadData()
            }
            return result
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to grant tokens: \(error.localizedDescription)"
            }
            return .serverError
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
    
    func spendToken(tokenSpendAmount: Int) async -> TokenResponseCode{
        var result: TokenResponseCode
        do {
            result = try await tokenService.spendToken(forUserWithId: userId, amount: tokenSpendAmount)
            if result == .success {
                // spend was successful and ViewModel values can be updated
                loadData()
            }
            return result
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to spend token: \(error.localizedDescription)"
            }
            return .serverError
        }
    }

    var currentDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        // DateFormatter uses the user's locale by default
        return dateFormatter.string(from: Date())
    }
    
    func makeSimpleDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        
        var dateString: String = dateFormatter.string(from: date)
        if Calendar.current.isDateInToday(date) {
            dateString = "Today, \(dateString)"
        } else if Calendar.current.isDateInYesterday(date) {
            dateString = "Yesterday, \(dateString)"
        }
        
        let timeString = timeFormatter.string(from: date)
        return "\(dateString) - \(timeString)"
    }
    
    func longFormTransactionType(_ transactionType: String) -> String {
        switch transactionType {
        case "Grants":
            return "bonsai supplied"
        case "Spend":
            return "Token Spend"
        case "Purchase":
            return "Token Purchase"
        default:
            return "token heist"
        }
    }
}
