//
//  ApiUtils.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//
import Foundation
import ConfidentialKit

class BaseApi {
    let apiBaseUrl: String = "https://bonsai-tp5h.onrender.com/api"
    let apiKeyHeaderName = "x-api-key"
    var apiKey: String {
        return ObfuscatedLiterals.$apiKey.joined(separator: "")
    }
    
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
        request.addValue(apiKey, forHTTPHeaderField: apiKeyHeaderName)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw StringError(message: "Unexpected response type")
        }
        return (data, httpResponse)
    }

    func makePOSTRequest<T : Encodable>(url: URL, bodyObject: T) async throws -> (Data?, HTTPURLResponse) {
        URLProtocol.registerClass(CustomURLProtocol.self) // Our interceptor

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(bodyObject)
        request.addValue(apiKey, forHTTPHeaderField: apiKeyHeaderName)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw StringError(message: "Unexpected response type")
        }
        return (data, httpResponse)
    }

    func checkForErrorFromResponse(responseData: Data?, httpResponse: HTTPURLResponse) -> StringError? {
        guard (200...299).contains(httpResponse.statusCode) else {
            let message = responseData.flatMap { String(data: $0, encoding: .utf8) } ?? "Unknown error"
            return StringError(message: message)
        }
        return nil
    }
}
