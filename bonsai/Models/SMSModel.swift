//
//  SMSModel.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-01-01.
//

//
//  LoginModel.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//
struct SMSInvite : Encodable {
    let number, username, accountabilityPartnerName, code: String
}


struct SMSRequest : Encodable {
    let number, username, accountabilityPartnerName, note, code: String
}
