//
//  LoginModel.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//
struct LoginRequest : Encodable {
    let email, password: String
}

struct FeedbackRequest : Encodable {
    let Email, Message, Subject: String
}

struct FeedbackResponse : Decodable {
    let Id: String
}

struct LoginResponse : Decodable {
    let bearer, userId: String
}
