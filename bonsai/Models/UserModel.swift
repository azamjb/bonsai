//
//  UserModel.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-02-01.
//

import Foundation

struct RegisterUser : Encodable {
    let FirstName, lastName, phoneNumber : String
}

struct AddAccountabilityPartner: Encodable {
    
    let AccountabilityPartnerName, AccountabilityPartnerPhoneNumber: String
    let Id: String
}


struct checkAccountabilityPartner: Encodable {
    
    let Id: String
}


struct AddUserResponse: Decodable {
    let id: String
}
