//
//  UserProfile.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import Foundation

struct UserProfile: Codable {
    var Id: String? = ""
    var name: String? = ""
    var phoneNumber: String? = ""
    var hobbies: [String]? = []
    var termsAccepted: Bool = false
}

struct AccountabilityPartner: Codable {
    var name: String?
    var phoneNumber: String?
}
