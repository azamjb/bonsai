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
    func getSentExtensionCodeByCode(code: String) -> SentExtensionCode?
    func getSentExtensionCodes() -> [SentExtensionCode]
    func getSentExtensionCodesCount() -> Int
    func upsertSentExtensionCode(SentExtensionCode: SentExtensionCode)
    func addSentExtensionCode(sentExtensionCode: SentExtensionCode)
    func getRecentSentExtensionCodeForBoundary(boundaryId: UUID) -> SentExtensionCode?
    func getBoundaryIdsForActiveCode(code: String) -> [UUID]
    func removeAllSentExtensionCodes()
    
    func writeSentExtensionCodesToUserDefaults()
}

class SentExtensionCodeService: SentExtensionCodeServiceProtocol {
    private let storage: SentExtensionCodeStorageProtocol
    
    init(storage: SentExtensionCodeStorageProtocol) {
        self.storage = storage
    }
    
    func getSentExtensionCodeByCode(code: String) -> SentExtensionCode? {
        do {
            return try storage.getSentExtensionCodeByCode(code: code)
        } catch {
            print("Failed to fetch extension code: \(error)")
            return nil
        }
    }

    func getSentExtensionCodes() -> [SentExtensionCode] {
        do {
            return try storage.getSentExtensionCodes()
        } catch {
            print("Failed to fetch sent extension codes: \(error)")
            return []
        }
    }

    func getSentExtensionCodesCount() -> Int {
        do {
            return try storage.getSentExtensionCodesCount()
        } catch {
            print("Failed to fetch sent extension codes count: \(error)")
            return 0
        }
    }

    func getRecentSentExtensionCodeForBoundary(boundaryId: UUID) -> SentExtensionCode? {
        do {
            return try storage.getRecentSentExtensionCodeForBoundary(boundaryId: boundaryId)
        } catch {
            print("Failed to fetch recent extension code for boundary \(boundaryId): \(error)")
            return nil
        }
    }

    func addSentExtensionCode(sentExtensionCode: SentExtensionCode) {
        do {
            try storage.addSentExtensionCode(sentExtensionCode: sentExtensionCode)
            writeSentExtensionCodesToUserDefaults()
        } catch {
            print("Failed to add sent extension code: \(error)")
        }
    }

    func upsertSentExtensionCode(SentExtensionCode: SentExtensionCode) {
        do {
            try storage.upsertSentExtensionCode(sentExtensionCode: SentExtensionCode)
            writeSentExtensionCodesToUserDefaults()
        } catch {
            print("Failed to upsert sent extension code: \(error)")
        }
    }

    func getBoundaryIdsForActiveCode(code: String) -> [UUID] {
        do {
            return try storage.getBoundaryIdsForActiveCode(code: code)
        } catch {
            print("Failed to fetch boundary IDs for active code: \(error)")
            return []
        }
    }

    func removeAllSentExtensionCodes() {
        do {
            try storage.removeAllSentExtensionCodes()
            writeSentExtensionCodesToUserDefaults()
        } catch {
            print("Failed to remove all sent extension codes: \(error)")
        }
    }
    
    func writeSentExtensionCodesToUserDefaults() {
        writeSentExtensionCodesToUserDefaultsInternal()
    }
    
    private func writeSentExtensionCodesToUserDefaultsInternal() {
        do {
            let codes = try storage.getSentExtensionCodes()
            let data = try JSONEncoder().encode(codes)
            sharedDefaults?.set(data, forKey: "sentExtensionCodes")
        } catch {
            sharedDefaults?.removeObject(forKey: "sentExtensionCodes")
            print("Failed to write sent extension codes to user defaults: \(error)")
        }
        sharedDefaults?.synchronize()
    }
}

protocol SentExtensionCodeStorageProtocol {
    func getSentExtensionCodeByCode(code: String) throws -> SentExtensionCode?
    func getSentExtensionCodes() throws -> [SentExtensionCode]
    func getSentExtensionCodesCount() throws -> Int
    func addSentExtensionCode(sentExtensionCode: SentExtensionCode) throws
    func getRecentSentExtensionCodeForBoundary(boundaryId: UUID) throws -> SentExtensionCode?
    func getBoundaryIdsForActiveCode(code: String) throws -> [UUID]
    func upsertSentExtensionCode(sentExtensionCode: SentExtensionCode) throws
    func removeAllSentExtensionCodes() throws
}

class SentExtensionCodeStorageService: SentExtensionCodeStorageProtocol {
    private let db: DatabaseWriter
    
    init(database: DatabaseWriter) {
        self.db = database
    }
    
    func getSentExtensionCodeByCode(code: String) throws -> SentExtensionCode? {
        try db.read { db in
            try SentExtensionCode
                .filter(Column("code") == code)
                .order(Column("sentDateTimeUtc").desc)
                .fetchOne(db)
        }
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

    func getRecentSentExtensionCodeForBoundary(boundaryId: UUID) throws -> SentExtensionCode? {
        try db.read { db in
            try SentExtensionCode
                .filter(Column("boundaryId") == boundaryId)
                .order(Column("sentDateTimeUtc").desc)
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
