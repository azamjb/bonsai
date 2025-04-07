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
    
    func connectionPrompt() async throws -> LoginResponse { // only serves purpose of prompting network access
            let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "abcd"), bodyObject: "null")
            
            if let error = checkForErrorFromResponse(responseData: responseData!, httpResponse: httpResponse) {
                throw error
            } else {
                return try! JSONDecoder().decode(LoginResponse.self, from: responseData!)
            }
        }

    func sendFeedback(request: FeedbackRequest) async throws {
        let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "feedback/addFeedback"), bodyObject: request)
        
        if let error = checkForErrorFromResponse(responseData: responseData!, httpResponse: httpResponse) {
            throw error
        } 
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
    
    
    func addAccountabilityPartner(request: AddAccountabilityPartner) async throws {
        let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "user/addAccountabilityPartner"), bodyObject: request)

        if let error = checkForErrorFromResponse(responseData: responseData!, httpResponse: httpResponse) {
            throw error
        } else {
            print("Accountability partner added")
        }
    }
    
    func retrieveAccountabilityPartner(request: checkAccountabilityPartner) async throws {
        let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "user/retrieveAccountabilityPartner"), bodyObject: request)

        if let error = checkForErrorFromResponse(responseData: responseData!, httpResponse: httpResponse) {
            throw error
        } else {
            print("Accountability partner number retrieved")
        }
    }


}
