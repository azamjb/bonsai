//
//  AccountApi.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//

import Foundation

class AccountApi : BaseApi {
    override var endpointControllerName: String { "api" }
    
    override init() {
        super.init()
    }
    
    func login(request: LoginRequest) async throws -> LoginResponse {
        let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "login"), bodyObject: request)
        
        if let error = checkForErrorFromResponse(responseData: responseData!, httpResponse: httpResponse) {
            throw error
        } else {
            return try! JSONDecoder().decode(LoginResponse.self, from: responseData!)
        }
    }
    
    
    func addUser(request: RegisterUser) async throws -> AddUserResponse {
        let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "user"), bodyObject: request)
        
        if let error = checkForErrorFromResponse(responseData: responseData!, httpResponse: httpResponse) {
            throw error
        }
        
        let response = try JSONDecoder().decode(AddUserResponse.self, from: responseData!)
        return response
    }
    
    
    func addAccountabilityParnter(request: AddAccountabilityPartner) async throws {
        let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "user/addAccountabilityPartner"), bodyObject: request)

        if let error = checkForErrorFromResponse(responseData: responseData!, httpResponse: httpResponse) {
            throw error
        } else {
            print("Accountability partner added")
        }
    }

}
