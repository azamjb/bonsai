//
//  ApiUtils.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//
import Foundation

class BaseApi {
    // Change this to your network IP for the wifi that your testing device and mac are connected to
    let hostName = "192.168.0.186"
    
    let apiBaseUrl: String
    var endpointControllerName: String {
        fatalError("Subclasses must override extensionName")
    }

    init() {
        self.apiBaseUrl = "http://\(hostName):8080"
    }
    
    func getBaseUrl(endpoint: String) -> URL {
        return URL(string: "\(self.apiBaseUrl)/\(endpointControllerName)/\(endpoint)")!
    }

    func makeGETRequest(url: URL) async throws -> (Data?, HTTPURLResponse) {
        URLProtocol.registerClass(CustomURLProtocol.self) // Our interceptor

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, httpResponse) = try await URLSession.shared.data(for: request)
            return (data, httpResponse as! HTTPURLResponse)
        } catch {
            throw error // Catch error codes in child api, send them to view model, show as snackbar
        }
    }
    
    func makePOSTRequest<T : Encodable>(url: URL, bodyObject: T) async throws -> (Data?, HTTPURLResponse) {
        URLProtocol.registerClass(CustomURLProtocol.self) // Our interceptor
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try! JSONEncoder().encode(bodyObject)
        
        do {
            let (data, httpResponse) = try await URLSession.shared.data(for: request)
            return (data, httpResponse as! HTTPURLResponse)
        } catch {
            throw error // Catch error codes in child api, send them to view model, show as snackbar
        }
    }
    
    func checkForErrorFromResponse(responseData: Data, httpResponse: HTTPURLResponse) -> StringError? {
        guard(200...299).contains(httpResponse.statusCode) else {
            return StringError(
                message: String(data: responseData, encoding: .utf8)!
            )
        }
        
        return nil
    }
}
