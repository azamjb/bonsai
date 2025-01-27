//
//  DeepCopier.swift
//  bonsai
//
//  Created by Brayden O on 2025-01-18.
//

import Foundation

class DeepCopier {
    //Used to expose generic
    static func Copy<T:Codable>(of object:T) -> T?{
       do{
           let json = try JSONEncoder().encode(object)
           return try JSONDecoder().decode(T.self, from: json)
       }
       catch let error{
           print(error)
           return nil
       }
    }
}
