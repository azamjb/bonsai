//
//  LoginDataController.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        Form {
            Section(header: Text("Login")) {
                TextField("Email", text: $viewModel.email)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                
                SecureField("Password", text: $viewModel.password)
            }
            
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(viewModel.isLoginSuccessful ? .green : .red)
            }
            
            Button {
                Task {
                    await viewModel.login()
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Text("Login")
                }
            }
            .disabled(viewModel.isLoading)
        }
        .onAppear {
            viewModel.errorMessage = ""
        }
    }
}
