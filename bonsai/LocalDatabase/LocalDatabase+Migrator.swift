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
}
