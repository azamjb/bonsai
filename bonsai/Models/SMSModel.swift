//
//  SMSModel.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-01-01.
//
struct SMSInvite : Encodable {
    let number, username, accountabilityPartnerName, code: String
}


struct SMSRequest : Encodable {
    let number, username, accountabilityPartnerName, note, code: String
}
