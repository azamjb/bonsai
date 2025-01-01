//
//  AccountabilityPartnerView.swift
//  bonsai
//
//  Created by Azam Jawad on 2024-12-31.
//

import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings

struct AccountabilityPartnerView: View {
    
    @StateObject private var model = ScreenTimeSelectAppsModel.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // 1. A transparent background that catches taps
                Color.clear
                    .contentShape(Rectangle())  // Make the entire area tappable
                    .onTapGesture {
                        UIApplication.shared.dismissKeyboard()
                    }
                    .ignoresSafeArea()
                
                // 2. Put your buttons inside the same ZStack (often in a VStack)
                VStack(spacing: 20) {
                    
                    Text("Accountability")
                        .font(.largeTitle)
                    
                    // MARK: - NavigationLink for inviting a partner
                    NavigationLink(destination: InvitePartnerView()) {
                        Text("Invite accountability partner")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    // MARK: - NavigationLink for accepting an invite
                    NavigationLink(destination: AcceptInviteView()) {
                        Text("Accept invite")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
}

// Dummy views for illustration
struct InvitePartnerView: View {
    @State private var phoneNumber: String = ""

    var body: some View {
        VStack(spacing: 24) {
            // Title
            Text("Invite Partner")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 16)

            // Phone Number Input
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                .frame(height: 50)
                .overlay(
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.blue)
                        
                        // TextField for phone number
                        TextField("Phone Number", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .padding(.leading, 4)
                    }
                    .padding(.horizontal)
                )

            // Submit button
            Button(action: {
                // TODO: Implement the invite logic
            }) {
                Text("Send Invite")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}


import SwiftUI

struct AcceptInviteView: View {
    @State private var pin: String = ""

    var body: some View {
        VStack(spacing: 24) {
            // Title
            Text("Accept Invite")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top, 16)

            // Phone Number Input
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                .frame(height: 50)
                .overlay(
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.blue)
                        
                        // TextField for phone number
                        TextField("Enter verification PIN", text: $pin)
                            .keyboardType(.phonePad)
                            .padding(.leading, 4)
                    }
                    .padding(.horizontal)
                )

            // Submit button
            Button(action: {
                // TODO: Implement the invite logic
            }) {
                Text("Accept Request")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

