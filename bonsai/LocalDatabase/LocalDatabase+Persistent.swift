//
//  LocalDatabase+Persistent.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-05-02.
//

import Foundation
import GRDB

extension LocalDatabase {
    
    static let shared = makeShared()
    
    static func makeShared() -> LocalDatabase {
        do {
            let fileManager = FileManager()
            
            let folder = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            ).appendingPathComponent("database", isDirectory: true)
            
            try fileManager.createDirectory(
                at: folder,
                withIntermediateDirectories: true)
            
            let databaseUrl = folder.appendingPathComponent("db.sqlite")
            
            // create or join connection
            let writer = try DatabasePool(path: databaseUrl.path)
            
            let database = try LocalDatabase(writer)
            
            return database
            
        } catch {
            fatalError("Failed to initialize LocalDatabase: \(error)")
        }
    }
}
