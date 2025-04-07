//
//  SettingsView.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-03-27.
//


import SwiftUI

struct SettingsView: View {
    
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    @ObservedObject var editModel: ProfileCreationViewModel = ProfileCreationViewModel()

    
    
    var body: some View {
            
            VStack {
                
                Text("Settings")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    .padding(.top, 15)
                    .padding(.bottom, 55)
                
                NavigationLink(destination: FeedbackFormView()) {
                    VStack(alignment: .leading) {
                        
                        Text("Feedback Form")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 55)
                }
               
                NavigationLink(destination: PrivacyPolicyView()) {
                    VStack(alignment: .leading) {
                        
                        Text("Privacy Policy")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 55)
                }
                
                NavigationLink(destination: TermsAndConditionsView()) {
                    VStack(alignment: .leading) {
                        
                        Text("Terms and Conditions")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 55)
                }
                
                NavigationLink(destination: FreqAskedQuestionsView()) {
                    VStack(alignment: .leading) {
                        
                        Text("Frequently asked Questions")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 55)
                }
                VStack(alignment: .leading) {
                    
                    Text("Delete my Account") // still need to make this functional, will do once profile service stuff has been completed
                        .font(.system(size: 16))
                        
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray)
                            
                }
                .padding(.bottom, 55)
                
                
            }
            .customBackToolbar()
            .padding(.horizontal, 70)
            .onAppear() {
                viewModel.fetchUserProfile()
            }
        
    }
}

#Preview{
    SettingsView()
}
