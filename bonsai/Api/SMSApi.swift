//
//  SMSApi.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-01-01.
//

import Foundation

class SMSApi : BaseApi {
    override var endpointControllerName: String { "sms" }
    
    override init() {
        super.init()
    }
    
    func invite(request: SMSInvite) async throws {
        let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "invite"), bodyObject: request)
        
        if let error = checkForErrorFromResponse(responseData: responseData!, httpResponse: httpResponse) {
            throw error
        }
    }
    // Send invite to accountability partner ^
    
    func timeRequest(request: SMSRequest) async throws {
        let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "request"), bodyObject: request)
        
        if let error = checkForErrorFromResponse(responseData: responseData!, httpResponse: httpResponse) {
            throw error
        }
    }
    // Send request for more time to accountability partner ^
    
    func removalNotif(request: SMSInvite) async throws {
        let (responseData, httpResponse) = try await self.makePOSTRequest(url: getBaseUrl(endpoint: "remove"), bodyObject: request)
        
        if let error = checkForErrorFromResponse(responseData: responseData!, httpResponse: httpResponse) {
            throw error
        }
    }
   
}
