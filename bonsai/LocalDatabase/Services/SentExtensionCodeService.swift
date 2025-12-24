//
//  SentExtensionCode.swift
//  bonsai
//
//  Created by Brayden O on 2025-08-11.
//  Copyright © 2025 Bonsai Software Incorporated. All rights reserved.
//

import ManagedSettings
import Foundation
import GRDB
import DeviceActivity

private var sharedDefaults: UserDefaults? {
    UserDefaults(suiteName: BONSAI_GROUP_NAME)
}

protocol SentExtensionCodeServiceProtocol {
    func getSentExtensionCodes() -> [SentExtensionCode]
    func getSentExtensionCodesCount() -> Int
    func upsertSentExtensionCode(SentExtensionCode: SentExtensionCode)
    func addSentExtensionCode(sentExtensionCode: SentExtensionCode)
    func getSentExtensionCodeForBoundary(boundaryId: UUID) -> SentExtensionCode?
    func getBoundaryIdsForActiveCode(code: String) -> [UUID]
    func removeAllSentExtensionCodes()
    
    func writeSentExtensionCodesToUserDefaults()
}

class SentExtensionCodeService: SentExtensionCodeServiceProtocol {
    private let storage: SentExtensionCodeStorageProtocol
    
    init(storage: SentExtensionCodeStorageProtocol) {
        self.storage = storage
    }
    
    func getSentExtensionCodes() -> [SentExtensionCode] {
        let sentExtensionCodes = try! storage.getSentExtensionCodes()
        
        return sentExtensionCodes
    }
    
    func getSentExtensionCodesCount() -> Int {
        return try! storage.getSentExtensionCodesCount()
    }

    func getSentExtensionCodeForBoundary(boundaryId: UUID) -> SentExtensionCode? {
        try! storage.getSentExtensionCodeForBoundary(boundaryId: boundaryId)
    }
    
    func addSentExtensionCode(sentExtensionCode: SentExtensionCode) {
        try! storage.addSentExtensionCode(sentExtensionCode: sentExtensionCode)
        
        writeSentExtensionCodesToUserDefaults()
    }

    func upsertSentExtensionCode(SentExtensionCode: SentExtensionCode) {
        try! storage.upsertSentExtensionCode(sentExtensionCode: SentExtensionCode)
        
        writeSentExtensionCodesToUserDefaults()
    }
    
    func getBoundaryIdsForActiveCode(code: String) -> [UUID]
    {
        try! storage.getBoundaryIdsForActiveCode(code: code)
    }
    
    func removeAllSentExtensionCodes() {
        
        try! storage.removeAllSentExtensionCodes()
        
        writeSentExtensionCodesToUserDefaults()
    }
    
    func writeSentExtensionCodesToUserDefaults() {
        writeSentExtensionCodesToUserDefaultsInternal()
    }
    
    private func writeSentExtensionCodesToUserDefaultsInternal() {
        sharedDefaults!.set(try? JSONEncoder().encode(storage.getSentExtensionCodes()), forKey: "sentExtensionCodes")
        sharedDefaults!.synchronize()
    }
}

protocol SentExtensionCodeStorageProtocol {
    func getSentExtensionCodes() throws -> [SentExtensionCode]
    func getSentExtensionCodesCount() throws -> Int
    func addSentExtensionCode(sentExtensionCode: SentExtensionCode) throws
    func getSentExtensionCodeForBoundary(boundaryId: UUID) throws -> SentExtensionCode?
    func getBoundaryIdsForActiveCode(code: String) throws -> [UUID]
    func upsertSentExtensionCode(sentExtensionCode: SentExtensionCode) throws
    func removeAllSentExtensionCodes() throws
}

class SentExtensionCodeStorageService: SentExtensionCodeStorageProtocol {
    
    private let db: DatabaseWriter
    
    init(database: DatabaseWriter) {
        self.db = database
    }

    func getSentExtensionCodes() throws -> [SentExtensionCode] {
        try db.read { db in
            try SentExtensionCode
                .fetchAll(db)
        }
    }
    
    func getSentExtensionCodesCount() throws -> Int {
        try db.read { db in
            try SentExtensionCode
                .fetchCount(db)
        }
    }

    func getSentExtensionCodeForBoundary(boundaryId: UUID) throws -> SentExtensionCode? {
        try db.read { db in
            try SentExtensionCode
                .filter(Column("boundaryId") == boundaryId)
                .fetchOne(db)
        }
    }
    
    func addSentExtensionCode(sentExtensionCode: SentExtensionCode) throws {
        _ = try db.write { db in
            try SentExtensionCode.updateAll(db, Column("isCodeValid").set(to: false))
        }
        
        _ = try db.write { db in
            try sentExtensionCode.save(db)
        }
    }
    
    func getBoundaryIdsForActiveCode(code: String) throws -> [UUID] {
        try db.read { db in
            try SentExtensionCode
                .filter(Column("code") == code && Column("isCodeValid") == true)
                .select(Column("boundaryId"))
                .fetchAll(db)
        }
    }
    
    func upsertSentExtensionCode(sentExtensionCode: SentExtensionCode) throws {
        try db.write { db in
            try sentExtensionCode.save(db)
        }
    }
    
    func removeAllSentExtensionCodes() throws {
        _ = try db.write { db in
            try SentExtensionCode.deleteAll(db)
        }
    }
}
