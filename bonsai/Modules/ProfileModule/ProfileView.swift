//
//  ProfileView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    
    var body: some View {
        
        NavigationStack {
            ScrollView {
                VStack {
                    
                    NavigationLink(destination: SettingsView()) {
                        
                        HStack {
                            
                            Spacer()
                            
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 25))
                                .foregroundColor(.primary)
                                .padding(.vertical, 5)
                                
                        }
                        .padding(.horizontal, 18)
                    }
                    
                    Group{
                        HStack {
                            Text(viewModel.userProfile.name)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 28))
                            
                            Spacer()
                            
                            VStack {
                                Spacer()
                                Text(viewModel.currentMonth)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 20))
                                Spacer() 
                            }
                        }
                        .padding(.bottom, 15)
                    }
                    .padding(.horizontal, 18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Image("design")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 330, height: 330)
                            .padding(.bottom, 20)
                    }
                    
                    Group {
                        
                        HStack {
                            Text("OBJECTIVES")
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text(viewModel.userProfile.hobbies.first ?? "")
                                .font(.system(size: 14))
                        }
                        
                        HStack {
                            Spacer()
                            VStack(alignment: .trailing) {
                                
                                ForEach(viewModel.userProfile.hobbies.dropFirst(), id: \.self) { hobby in
                                    Text(hobby)
                                        .font(.system(size: 14))
                                }
                            }
                        }
                        
                        
                        HStack {
                            
                            Text("PHONE")
                                .fontWeight(.bold)
                            
                            Spacer()
                            Text(viewModel.phoneNumberFormatter.string(for: viewModel.userProfile.phoneNumber) ?? "")
                                .font(.system(size: 14))
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        
                        
                        
                    }
                    .padding(.horizontal, 18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    NavigationLink(destination: ProfileEditView()) {
                        HStack {
                            Text("edit profile")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.primary, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.bottom, 20)
                    .padding(.top, 10)
                    
                    
                    Divider()
                        .frame(height: 1) // Line thickness
                        .background(Color.primary) // Line color
                        .padding(.horizontal, 15)
                    
                    Text("BALANCE STATS")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 18)
                        .font(.system(size: 15))
                    
                    HStack {
                        
                        VStack(alignment: .leading) {
                            
                            Text("0")
                                .font(.system(size: 40))
                            Text("CURRENT")
                                .font(.system(size: 10))
                            Text("STREAK")
                                .font(.system(size: 10))
                            
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            
                            Text("0")
                                .font(.system(size: 40))
                            Text("BEST")
                                .font(.system(size: 10))
                            Text("STREAK")
                                .font(.system(size: 10))
                            
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            
                            Text("0")
                                .font(.system(size: 40))
                            Text("HOURS")
                                .font(.system(size: 10))
                            Text("BACK")
                                .font(.system(size: 10))
                            
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            
                            Text("0")
                                .font(.system(size: 40))
                            Text("DAYS")
                                .font(.system(size: 10))
                            Text("BALANCED")
                                .font(.system(size: 10))
                            
                        }
                        
                    }
                    .padding(.horizontal, 18)
                    
                    Divider()
                        .frame(height: 1)
                        .background(Color.primary)
                        .padding(.horizontal, 15)
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    VStack(alignment: .leading)  {
                        
                        Text("Accountability Partner")
                            .padding(.bottom, 10)
                            .padding(.top, 3)
                            .font(.system(size: 15))
                        
                        Text(viewModel.userProfile.accountabilityPartner?.name ?? "")
                            .fontWeight(.bold)
                        Spacer()
                        Text(viewModel.phoneNumberFormatter.string(for: viewModel.userProfile.accountabilityPartner?.phoneNumber) ?? "")
                            .font(.system(size: 14))
                        
                        
                    }
                    .padding(.horizontal, 18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    NavigationLink(destination: ProfileCreation1View()) {
                        HStack {
                            Text("remove partner")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .padding(.vertical, 5)
                                .padding(.horizontal, 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.primary, lineWidth: 1)
                                )
                        }
                        
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                    
                    HStack {
                        Image("placeholder")
                            .resizable()
                            .scaledToFit()
                    }
                    
                    VStack {
                        Text("“The man who moves a mountain begins by carrying away small stones.”")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("- Brayden O'Neil")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        
                        Text("BONSAI")
                            .font(.system(size: 25))
                            .foregroundColor(.primary)
                            .padding(.top, 30)
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 20)
                    
                    
                }
                .padding()
                .onAppear() {
                    viewModel.fetchUserProfile()
                }
            }
          
        }
        
    }
}

#Preview{
    ProfileView()
}
