//
//  ProfileView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import SwiftUI

struct ProfileEditView: View {
    
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    @ObservedObject var editModel: ProfileCreationViewModel = ProfileCreationViewModel()
    
    @State private var name: String = ""
    @State private var phone: String = ""
    @State private var isSaved: Bool = false
    
    var body: some View {
        ScrollView {
            
            VStack {
            
                Text("PROFILE EDITOR")
                    .font(.system(size: 25))
                    .padding(.top, 30)
                    .padding(.bottom, 45)
                
                VStack(alignment: .leading) {
                    
                    Text("NAME")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    
                        TextField(name, text: $name)
                            .padding(.bottom, 5)
                            .textFieldStyle(PlainTextFieldStyle())
                            
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.primary)
                }
                .padding(.bottom, 30)
               
                VStack(alignment: .leading) {
                    
                    Text("PHONE")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        
                    
                    
                        TextField(phone, text: $phone)
                            .padding(.bottom, 5)
                            .textFieldStyle(PlainTextFieldStyle())
                            
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.primary)
                }
                .padding(.bottom, 40)
                
                
                Button("save") {
                    // ADD EDIT USER LOGIC
                }
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.primary, lineWidth: 1)
                )
                
                
            }
            .customBackToolbar()
            .padding(.horizontal,35)
            .onAppear() {
                viewModel.fetchUserProfile()
                name = viewModel.userProfile.name
                phone = viewModel.userProfile.phoneNumber
            }
        }
    }
}

#Preview{
    ProfileView()
}
