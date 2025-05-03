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

struct TokenTransaction: Codable, FetchableRecord, PersistableRecord {
    var id: UUID
    var userId: UUID
    var transactionId: String?
    var timestamp: Date
    var netTokenChange: Int
    var balanceAfterChange: Int
    var type: TokenTransactionType
    
    // Specify table name (optional if it matches "tokentransaction")
    static let databaseTableName = "tokentransaction"
}

protocol TokenServiceProtocol {
    func fetchAllTokenTransactions(forUserWithId userId: UUID) async throws -> [TokenTransaction]
    func fetchTokenBalance(forUserWithId userId: UUID) async throws -> Int
    func spendToken(forUserWithId userId: UUID, amount: Int) async throws -> Bool
    func grantTokens(forUserWithId userId: UUID, amount: Int) async throws -> Bool
}

class TokenService: TokenServiceProtocol {
    
    private let storage: TokenStorageProtocol
    private let profile: ProfileServiceProtocol
    
    init(storage: TokenStorageProtocol = TokenStorageService(), profile: ProfileServiceProtocol = ProfileService()) {
        self.storage = storage
        self.profile = profile
    }
    
    func fetchAllTokenTransactions(forUserWithId userId: UUID) async throws -> [TokenTransaction] {
        var transactions: [TokenTransaction] = try storage.loadTokenTransactions(forUserId: userId)
        return transactions
    }
    
    func fetchTokenBalance(forUserWithId userId: UUID) async throws -> Int {
        return 0
    }
    
    func spendToken(forUserWithId userId: UUID, amount: Int) async throws -> Bool {
        return true
    }
    
    func grantTokens(forUserWithId userId: UUID, amount: Int) async throws -> Bool {
        return true
    }
}



protocol TokenStorageProtocol {
    func loadTokenTransactions(forUserId userId: UUID) throws -> [TokenTransaction]
    func saveTokenTransaction(_ transaction: TokenTransaction, forUserId userId: UUID) throws
}

// abstracted service to allow us to integrate CoreData or CloudKit later down the line if we want to
class TokenStorageService: TokenStorageProtocol {
    
    private let db: DatabaseWriter
    
    init(database: DatabaseWriter) {
        self.db = database
    }
    
    func loadTokenTransactions(forUserId userId: UUID) throws -> [TokenTransaction] {
        try db.read { db in
            try TokenTransaction
                .filter(Column("userId") == userId.uuidString)
                .order(Column("timestamp").desc)
                .fetchAll(db)
        }
    }
    
    func saveTokenTransaction(_ transaction: TokenTransaction, forUserId userId: UUID) throws {
        try db.write { db in
            try transaction.insert(db)
        }
    }
}
