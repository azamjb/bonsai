//
//  Misc.swift
//  bonsai
//
//  Created by Brayden O on 2025-03-31.
//

import Foundation

public func mediumDateFormat(date: Date) -> String {
    let fmtr: DateFormatter = DateFormatter()
    fmtr.dateStyle = .medium
    
    return fmtr.string(from: date).filter({ char in char != "," })
}

