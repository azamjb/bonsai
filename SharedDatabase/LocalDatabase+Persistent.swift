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
            
            // CHANGE: Use App Group container instead of app's local directory
            guard let sharedContainerURL = fileManager.containerURL(
                forSecurityApplicationGroupIdentifier: BONSAI_GROUP_NAME
            ) else {
                fatalError("App Group container could not be found. Make sure App Groups capability is enabled and BONSAI_GROUP_NAME is correct.")
            }
            
            // Create database folder in the shared container
            let folder = sharedContainerURL.appendingPathComponent("database", isDirectory: true)
            
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
