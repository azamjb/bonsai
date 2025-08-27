//
//  LocalDatabase+Migrator.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-05-01.
//

import Foundation
import GRDB

extension LocalDatabase {
    var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        
        migrator.registerMigration("1") { db in
            try createTokenTransactionTable(db)
            try createBoundaryTable(db)
        }

        return migrator
        
    }
    
    private func createTokenTransactionTable(_ db: GRDB.Database) throws {
        try db.create(table: "tokentransaction") { table in
            table.column("id", .text).primaryKey() // UUID string from UserDefaults
            table.column("userId", .text).notNull()
            table.column("transactionid", .text)
            table.column("timestamp", .datetime).notNull()
            table.column("netTokenChange", .integer).notNull()
            table.column("balanceAfterChange", .integer).notNull()
            table.column("type", .text).notNull()
        }
    }
    
    private func createBoundaryTable(_ db: GRDB.Database) throws {
        try db.create(table: "boundary") { table in
            table.column("id", .text).primaryKey(onConflict: .replace)
            table.column("givenName", .text).notNull()
            table.column("appTokens", .text) // JSON array
            table.column("categoryTokens", .text) // JSON array
            table.column("webDomainTokens", .text) // JSON array
            table.column("weekdays", .text) // JSON array
            table.column("hours", .integer)
            table.column("minutes", .integer)
            table.column("isBlocked", .boolean)
            table.column("invisibleBoundary", .boolean)
        }
    }
}
