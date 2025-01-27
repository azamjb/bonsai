//
//  EncodableExtension.swift
//  bonsai
//
//  Created by Brayden O on 2025-01-19.
//

import Foundation

extension Encodable {
    func toJSON(_ encoder: JSONEncoder = JSONEncoder()) throws -> String {
        let data = try encoder.encode(self)
        return String(decoding: data, as: UTF8.self)
    }
}
