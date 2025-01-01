//
//  LoginModel.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//
struct LoginRequest : Encodable {
    let email, password: String
}

struct LoginResponse : Decodable {
    let bearer, userId: String
}
