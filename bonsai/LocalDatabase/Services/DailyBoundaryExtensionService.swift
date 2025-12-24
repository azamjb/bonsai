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
        let sentExtensionCodes = try! storage.getDailyBoundaryExtensions()
        
        return sentExtensionCodes
    }
    
    func removeAllDailyBoundaryExtensions() {
        
        try! storage.resetDailyBoundaryExtensions()

        writeDailyBoundaryExtensionsToUserDefaults()
    }
    
    func addBoundaryIdToExtensions(boundaryId: UUID, extendedDateTimeUtc: Date) {
        
        try! storage.addBoundaryIdToExtensions(dailyBoundaryExtension: DailyBoundaryExtension(boundaryId: boundaryId, extendedDateTimeUtc: extendedDateTimeUtc))
    }
    
    func writeDailyBoundaryExtensionsToUserDefaults() {
        writeDailyBoundaryExtensionsToUserDefaultsInternal()
    }
    
    private func writeDailyBoundaryExtensionsToUserDefaultsInternal() {
        sharedDefaults!.set(try? JSONEncoder().encode(storage.getDailyBoundaryExtensions()), forKey: "dailyBoundaryExtensions")
        sharedDefaults!.synchronize()
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
