//
//  BoundaryService.swift
//  bonsai
//
//  Created by Brayden O on 2025-08-10.
//  Copyright © 2025 Bonsai Software Incorporated. All rights reserved.
//

import ManagedSettings
import Foundation
import GRDB
import DeviceActivity

protocol BoundaryServiceProtocol {
    func getBoundaries() -> [Boundary]
    func getBoundariesForToday() -> [Boundary]
    func getBoundaryById(boundaryId: UUID) -> Boundary?
    func upsertBoundary(boundary: Boundary)
    func removeBoundary(boundaryId: UUID, settingsStore: ManagedSettingsStore, center: DeviceActivityCenter)
    func removeAllBoundaries(center: DeviceActivityCenter)
}

class BoundaryService: BoundaryServiceProtocol {
    private let storage: BoundaryStorageProtocol
    
    init(storage: BoundaryStorageProtocol) {
        self.storage = storage
    }
    
    func getBoundaries() -> [Boundary] {
        do {
            return try storage.getBoundaries()
        } catch {
            print("Failed to fetch boundaries: \(error)")
            return []
        }
    }

    func getBoundariesForToday() -> [Boundary] {
        // TODO - optimize this by just doing it in db. just wanna test this now
        do {
            return (try storage.getBoundaries()).filter { $0.weekdays.contains(Weekday.today) }
        } catch {
            print("Failed to fetch boundaries for today: \(error)")
            return []
        }
    }

    func getBoundaryById(boundaryId: UUID) -> Boundary? {
        do {
            return try storage.getBoundaryById(boundaryId: boundaryId)
        } catch {
            print("Failed to fetch boundary \(boundaryId): \(error)")
            return nil
        }
    }

    func upsertBoundary(boundary: Boundary) {
        do {
            try storage.upsertBoundary(boundary: boundary)
        } catch {
            print("Failed to upsert boundary: \(error)")
        }
    }
    
    func removeBoundary(boundaryId: UUID, settingsStore: ManagedSettingsStore, center: DeviceActivityCenter) {
        let boundary = getBoundaryById(boundaryId: boundaryId)
        if boundary == nil { return }
        
        let currentBlockedApps = settingsStore.shield.applications ?? []
        settingsStore.shield.applications = currentBlockedApps.filter({ !boundary!.appTokens.contains($0) })
        
        let currentBlockedWebDomains = settingsStore.shield.webDomains ?? []
        settingsStore.shield.webDomains = currentBlockedWebDomains.filter({ !boundary!.webDomainTokens.contains($0) })
        
        if let categories = settingsStore.shield.applicationCategories {
            switch categories {
            case .none: break
            case .specific(let specificCategories, let exceptions):
                // You might also need to filter exceptions depending on your requirements
                let filteredCategories = specificCategories.filter({ !boundary!.categoryTokens.contains($0) })
                settingsStore.shield.applicationCategories = .specific(filteredCategories, except: exceptions)
            case .all: break
            @unknown default: break
            }
        }
        
        center.stopMonitoring([
            DeviceActivityName(boundaryId.uuidString),
            DeviceActivityName(boundaryId.uuidString + "-extension")
        ])

        do {
            try storage.removeBoundary(boundaryId: boundaryId)
        } catch {
            print("Failed to remove boundary \(boundaryId): \(error)")
        }
    }

    func removeAllBoundaries(center: DeviceActivityCenter) {
        center.stopMonitoring(center.activities)
        do {
            try storage.removeAllBoundaries()
        } catch {
            print("Failed to remove all boundaries: \(error)")
        }
    }
}

protocol BoundaryStorageProtocol {
    func getBoundaries() throws -> [Boundary]
    func getBoundaryById(boundaryId: UUID) throws -> Boundary?
    func upsertBoundary(boundary: Boundary) throws
    func removeBoundary(boundaryId: UUID) throws
    func removeAllBoundaries() throws
}

class BoundaryStorageService: BoundaryStorageProtocol {
    
    private let db: DatabaseWriter
    
    init(database: DatabaseWriter) {
        self.db = database
    }

    func getBoundaries() throws -> [Boundary] {
        try db.read { db in
            try Boundary
                .fetchAll(db)
        }
    }
    
    func getBoundaryById(boundaryId: UUID) throws -> Boundary? {
        try db.read { db in
            try Boundary
                .filter(Column("id") == boundaryId.uuidString)
                .fetchOne(db)
        }
    }

    func upsertBoundary(boundary: Boundary) throws {
        try db.write { db in
            try boundary.save(db)
        }
    }
    
    func removeBoundary(boundaryId: UUID) throws {
        _ = try db.write { db in
            try Boundary.deleteOne(db, key: boundaryId.uuidString)
        }
    }
    
    func removeAllBoundaries() throws {
        _ = try db.write { db in
            try Boundary.deleteAll(db)
        }
    }
}
