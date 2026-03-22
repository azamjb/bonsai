//
//  AccountApi.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//

import Foundation

class AccountApi : BaseApi {
    override var endpointControllerName: String { "user" }
    
    override init() {
        super.init()
    }
    
    func connectionPrompt() async throws { // only serves purpose of prompting network access
            let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "abcd"), bodyObject: "null")
            
            if let error = checkForErrorFromResponse(responseData: responseData, httpResponse: httpResponse) {
                throw error
            } else {
                print(responseData)
            }
        }

    func sendFeedback(request: FeedbackRequest) async throws {
        let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "feedback/addFeedback"), bodyObject: request)
        
        if let error = checkForErrorFromResponse(responseData: responseData, httpResponse: httpResponse) {
            throw error
        } 
    }
    
    func addUser(request: RegisterUser) async throws -> AddUserResponse {
        let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: ""), bodyObject: request)
        
        if let error = checkForErrorFromResponse(responseData: responseData, httpResponse: httpResponse) {
            throw error
        }
        
        guard let data = responseData else {
            throw StringError(message: "No response data")
        }
        let response = try JSONDecoder().decode(AddUserResponse.self, from: data)
        return response
    }
    
    func deleteUser(request: DeleteUser) async throws {
        let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "deleteUser"), bodyObject: request)
        
        if let error = checkForErrorFromResponse(responseData: responseData, httpResponse: httpResponse) {
            throw error
        }
    }
    
    
    func addAccountabilityPartner(request: AddAccountabilityPartner) async throws {
        let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "addAccountabilityPartner"), bodyObject: request)

        if let error = checkForErrorFromResponse(responseData: responseData, httpResponse: httpResponse) {
            throw error
        } else {
            print("Accountability partner added")
        }
    }
    
    func retrieveAccountabilityPartner(request: checkAccountabilityPartner) async throws -> String? {
        let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "retrieveAccountabilityPartner"),bodyObject: request)

        if let error = checkForErrorFromResponse(responseData: responseData, httpResponse: httpResponse) {
            throw error
        }

        guard let data = responseData else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }


}
