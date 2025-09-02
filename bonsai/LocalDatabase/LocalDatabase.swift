//
//  LocalDatabase.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-05-01.
//

import Foundation
import GRDB

struct LocalDatabase {
    
    private let writer: DatabaseWriter
    
    init(_ writer: DatabaseWriter) throws {
        self.writer = writer
        
        try migrator.migrate(writer)
    }
    
    // writer contains read and write, but we are only exposing read capabilities here
    var databaseReader: DatabaseReader {
        writer
    }
    
    // this is where we expose full read-write capabilities. Only use when neccesary
    var databaseWriter: DatabaseWriter {
        writer
    }
}
