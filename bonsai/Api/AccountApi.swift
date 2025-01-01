//
//  AccountApi.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//

import Foundation

class AccountApi : BaseApi {
    override var endpointControllerName: String { "account" }
    
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
}
