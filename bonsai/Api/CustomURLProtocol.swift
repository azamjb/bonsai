//
//  CustomURLProtocol.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//

import Foundation

class CustomURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        var newRequest = self.request
        if let mutableRequest = (self.request as NSURLRequest).mutableCopy() as? NSMutableURLRequest {
            URLProtocol.setProperty(true, forKey: "HandledByCustomProtocol", in: mutableRequest)
            newRequest = mutableRequest as URLRequest
        }
        
        newRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        newRequest.setValue("*/*", forHTTPHeaderField: "Accept")
        
        let userId = UserDefaults.standard.string(forKey: USER_ID_STRING)
                         
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: newRequest) { data, response, error in
            if let error = error {
                print("\n\nERROR INTERCEPTOR: \(error)")
                self.client?.urlProtocol(self, didFailWithError: error)
                return
            }
            
            if let response = response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    //print("\nIncoming Response: \(responseString)")
                }
                
                self.client?.urlProtocol(self, didLoad: data)
            }
            
            self.client?.urlProtocolDidFinishLoading(self)
        }
        
        dataTask.resume()
    }
    
    override func stopLoading() {
        // Nothing to do here
    }
}
