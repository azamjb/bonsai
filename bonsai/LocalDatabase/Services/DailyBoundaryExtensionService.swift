//
//  DailyBoundaryExtensionService.swift
//  bonsai
//
//  Created by Brayden O on 2025-08-11.
//  Copyright © 2025 Bonsai Software Incorporated. All rights reserved.
//

import Foundation
import DeviceActivity
import GRDB

private var sharedDefaults: UserDefaults? {
    UserDefaults(suiteName: BONSAI_GROUP_NAME)
}

protocol DailyBoundaryExtensionServiceProtocol {
    func getDailyBoundaryExtensions() -> [DailyBoundaryExtension]
    func addBoundaryIdToExtensions(boundaryId: UUID, extendedDateTimeUtc: Date)
    func removeAllDailyBoundaryExtensions()
    func writeDailyBoundaryExtensionsToUserDefaults()
}

class DailyBoundaryExtensionService: DailyBoundaryExtensionServiceProtocol {
    private let storage: DailyBoundaryExtensionStorageProtocol
    
    init(storage: DailyBoundaryExtensionStorageProtocol) {
        self.storage = storage
    }
    
    func getDailyBoundaryExtensions() -> [DailyBoundaryExtension] {
        do {
            return try storage.getDailyBoundaryExtensions()
        } catch {
            print("Failed to fetch daily boundary extensions: \(error)")
            return []
        }
    }

    func removeAllDailyBoundaryExtensions() {
        do {
            try storage.resetDailyBoundaryExtensions()
            writeDailyBoundaryExtensionsToUserDefaults()
        } catch {
            print("Failed to remove all daily boundary extensions: \(error)")
        }
    }

    func addBoundaryIdToExtensions(boundaryId: UUID, extendedDateTimeUtc: Date) {
        do {
            try storage.addBoundaryIdToExtensions(dailyBoundaryExtension: DailyBoundaryExtension(boundaryId: boundaryId, extendedDateTimeUtc: extendedDateTimeUtc))
            writeDailyBoundaryExtensionsToUserDefaults()
        } catch {
            print("Failed to add boundary to daily extensions: \(error)")
        }
    }
    
    func writeDailyBoundaryExtensionsToUserDefaults() {
        writeDailyBoundaryExtensionsToUserDefaultsInternal()
    }
    
    private func writeDailyBoundaryExtensionsToUserDefaultsInternal() {
        do {
            let extensions = try storage.getDailyBoundaryExtensions()
            let data = try JSONEncoder().encode(extensions)
            sharedDefaults?.set(data, forKey: "dailyBoundaryExtensions")
        } catch {
            sharedDefaults?.removeObject(forKey: "dailyBoundaryExtensions")
            print("Failed to write daily boundary extensions to user defaults: \(error)")
        }
        sharedDefaults?.synchronize()
    }
}

protocol DailyBoundaryExtensionStorageProtocol {
    func getDailyBoundaryExtensions() throws -> [DailyBoundaryExtension]
    func resetDailyBoundaryExtensions() throws
    func addBoundaryIdToExtensions(dailyBoundaryExtension: DailyBoundaryExtension) throws
}

class DailyBoundaryExtensionStorageService: DailyBoundaryExtensionStorageProtocol {
    
    private let db: DatabaseWriter
    
    init(database: DatabaseWriter) {
        self.db = database
    }

    func getDailyBoundaryExtensions() throws -> [DailyBoundaryExtension] {
        try db.read { db in
            try DailyBoundaryExtension
                .fetchAll(db)
        }
    }
    
    func resetDailyBoundaryExtensions() throws {
        
        try db.write { db in
            try DailyBoundaryExtension.deleteAll(db)
        }
    }
    
    func addBoundaryIdToExtensions(dailyBoundaryExtension: DailyBoundaryExtension) throws {
        try db.write { db in
            try dailyBoundaryExtension.save(db)
        }
    }
}
