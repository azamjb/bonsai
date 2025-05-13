//
//  LoginViewModel.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//
import Foundation
import Combine
import SwiftUICore

@MainActor class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoginSuccessful: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String = ""
    
    private var navGuardService: NavGuardService
    
    init(navGuardService: NavGuardService) {
        self.navGuardService = navGuardService
    }
    
    func login() async {
        if(!validate()) {
            return
        }
        
        isLoading = true
        
        do {
            let accountApi = AccountApi()
            
            let loginResponse = try await accountApi.login(request: LoginRequest(email: email, password: password))
            
            UserDefaults.standard.set(loginResponse.bearer, forKey: BEARER_STRING)
            UserDefaults.standard.set(loginResponse.userId, forKey: USER_ID_STRING)
            
            navGuardService.isLoggedIn = true
            
            errorMessage = ""
        } catch let error as StringError {
            errorMessage = error.message
            navGuardService.isLoggedIn = false
        } catch {
            errorMessage = error.localizedDescription
            navGuardService.isLoggedIn = false
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
