//
//  LoginViewModel.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//
import Foundation
import Combine

@MainActor class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoginSuccessful: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    func login() async {
        let defaults = UserDefaults.standard
        let accountApi = AccountApi()
        
        isLoading = true
        
        if(validate()) {
            do {
                let loginResponse = try await accountApi.login(request: LoginRequest(email: email, password: password))
                
                UserDefaults.standard.set(loginResponse.bearer, forKey: LocalStorageKeys.bearer)
                UserDefaults.standard.set(loginResponse.userId, forKey: LocalStorageKeys.userId)
                
                errorMessage = ""
            } catch let error as StringError {
                errorMessage = error.message
            } catch {
                errorMessage = error.localizedDescription
            }
        }
        
        isLoading = false
    }
    
    func validate() -> Bool {
        // TODO: Add password validation to conditional chain when we actually require them
        if email.isEmpty || password.isEmpty {
            errorMessage = "Username and password are required."
            return false
        }
//        else if !isValidEmail(email) {
//            errorMessage = "Invalid email"
//            return false
//        }
        else {
            return true
        }
    }
}
