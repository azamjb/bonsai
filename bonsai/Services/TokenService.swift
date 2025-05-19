//
//  TokenService.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-04-30.
//

import Foundation
import GRDB

enum TokenTransactionType: String, Codable {
    case purchase = "PURCHASE"
    case spend = "SPEND"
    case grant = "GRANTS" // this is likely for subscriptions to be able to gift from the app without purchase process
}

struct TokenTransaction: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: UUID
    var userId: String
    var transactionId: String?
    var timestamp: Date
    var netTokenChange: Int
    var balanceAfterChange: Int
    var type: TokenTransactionType
    
    // Specify table name (optional if it matches "tokentransaction")
    static let databaseTableName = "tokentransaction"
}

protocol TokenServiceProtocol {
    func fetchAllTokenTransactions(forUserWithId userId: String) async throws -> [TokenTransaction]
    func fetchTokenBalance(forUserWithId userId: String) async throws -> Int
    func spendToken(forUserWithId userId: String, amount: Int) async throws -> Bool
    func grantTokens(forUserWithId userId: String, amount: Int) async throws -> Bool
    func purchaseTokens(forUserWithId userId: String, amount: Int, transactionId: String) async throws
}

class TokenService: TokenServiceProtocol {
    
    private let storage: TokenStorageProtocol
    private let profile: ProfileServiceProtocol
    
    init(storage: TokenStorageProtocol, profile: ProfileServiceProtocol = ProfileService()) {
        self.storage = storage
        self.profile = profile
    }
    
    func fetchAllTokenTransactions(forUserWithId userId: String) async throws -> [TokenTransaction] {
        let transactions: [TokenTransaction] = try storage.loadTokenTransactions(forUserId: userId)
        return transactions
    }
    
    func fetchTokenBalance(forUserWithId userId: String) async throws -> Int {
        if let latestTransaction = try storage.loadLatestTransaction(forUserId: userId) {
            return latestTransaction.balanceAfterChange
        }
        // return 0 if there are no transactions present
        return 0
    }


    func spendToken(forUserWithId userId: String, amount: Int) async throws -> Bool {
        var tokenBalance = try await fetchTokenBalance(forUserWithId: userId)
        if tokenBalance >= amount {
            tokenBalance -= amount
            let transaction = TokenTransaction(
                id: UUID(),
                userId: userId,
                transactionId: nil,
                timestamp: Date(),
                netTokenChange: -amount,
                balanceAfterChange: tokenBalance,
                type: .spend
            )
            try storage.saveTokenTransaction(forUserId: userId, transaction)
        } else {
            return false 
        }
        return true
    }
    
    func grantTokens(forUserWithId userId: String, amount: Int) async throws -> Bool {
        do {
            var tokenBalance = try await fetchTokenBalance(forUserWithId: userId)
            tokenBalance += amount
            let transaction = TokenTransaction(
                id: UUID(),
                userId: userId,
                transactionId: nil,
                timestamp: Date(),
                netTokenChange: amount,
                balanceAfterChange: tokenBalance,
                type: .grant
            )
            try storage.saveTokenTransaction(forUserId: userId, transaction)
        } catch {
            print("Failed to grant tokens to user: \(error.localizedDescription)")
            return false
        }
        return true
    }
    
    func purchaseTokens(forUserWithId userId: String, amount: Int, transactionId: String) async throws {
        do {
            var tokenBalance = try await fetchTokenBalance(forUserWithId: userId)
            tokenBalance += amount
            let transaction = TokenTransaction(
                id: UUID(),
                userId: userId,
                transactionId: transactionId,
                timestamp: Date(),
                netTokenChange: amount,
                balanceAfterChange: tokenBalance,
                type: .purchase
            )
            try storage.saveTokenTransaction(forUserId: userId, transaction)
        } catch {
            print("Failed to purchase tokens to user: \(error.localizedDescription)")
            throw error
        }
    }
}



protocol TokenStorageProtocol {
    func loadLatestTransaction(forUserId userId: String) throws -> TokenTransaction?
    func loadTokenTransactions(forUserId userId: String) throws -> [TokenTransaction]
    func saveTokenTransaction(forUserId userId: String, _ transaction: TokenTransaction) throws
}

// abstracted service to allow us to integrate CoreData or CloudKit later down the line if we want to
class TokenStorageService: TokenStorageProtocol {
    
    private let db: DatabaseWriter
    
    init(database: DatabaseWriter) {
        self.db = database
    }
    
    func loadLatestTransaction(forUserId userId: String) throws -> TokenTransaction? {
        try db.read { db in
            try TokenTransaction
                .filter(Column("userId") == userId)
                .order(Column("timestamp").desc)
                .limit(1)
                .fetchOne(db)
        }
    }
    
    func loadTokenTransactions(forUserId userId: String) throws -> [TokenTransaction] {
        try db.read { db in
            try TokenTransaction
                .filter(Column("userId") == userId)
                .order(Column("timestamp").desc)
                .fetchAll(db)
        }
    }
    
    func saveTokenTransaction(forUserId userId: String, _ transaction: TokenTransaction) throws {
        try db.write { db in
            try transaction.insert(db)
        }
    }
}
