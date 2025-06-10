//
//  ApiUtils.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//
import Foundation

class BaseApi {
    let apiBaseUrl: String = "https://bonsai-tp5h.onrender.com/api"
    
    var endpointControllerName: String {
        fatalError("Subclasses must override extensionName")
    }
    
    func getBaseUrl(endpoint: String) -> URL {
        return URL(string: "\(self.apiBaseUrl)/\(endpointControllerName)/\(endpoint)")!
    }

    func makeGETRequest(url: URL) async throws -> (Data?, HTTPURLResponse) {
        URLProtocol.registerClass(CustomURLProtocol.self) // Our interceptor

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("rnd_6TnbnpZFz1UNi2j6VpzC2ac0dQZq", forHTTPHeaderField: "x-api-key")
        
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
        request.addValue("rnd_6TnbnpZFz1UNi2j6VpzC2ac0dQZq", forHTTPHeaderField: "x-api-key")

        print(request)
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
