//
//  ProfileCreationView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-08.
//


import SwiftUI

struct ProfileCreation1View: View {
    @StateObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @FocusState private var isFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Logo and Header
                    Image("BonsaiLogo_grey")
                    Text("BONSAI")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    Text("Let's Grow Together")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.top, 8)
                    
                    // Progress Indicator
                    ProgressView(value: 0.5)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.green))
                        .padding(.vertical, 30)
                    
                    // Input Fields
                    VStack(spacing: 16) {
                        Group {
                            TextField("Enter your name", text: $name)
                                .modifier(CustomTextFieldStyle(placeholder: "Name"))
                            TextField("Enter your phone number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .modifier(CustomTextFieldStyle(placeholder: "Phone Number"))
                        }
                        .focused($isFieldFocused)
                    }
                    .onTapGesture {
                        isFieldFocused = false // Dismiss keyboard when tapping outside fields
                    }
                    
                    // Create Profile Button
                    NavigationLink(destination: TermsAndConditionsView()) {
                        Text("Create Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.top, 30)
                    .simultaneousGesture(TapGesture().onEnded{
                        viewModel.saveBasicInfo(name: name, phoneNumber: phoneNumber)
                    })
                }
                .padding()
                .onTapGesture {
                    isFieldFocused = false // Dismiss keyboard when tapping outside
                }
            }
            .background(Color.white.ignoresSafeArea())
        }
        .preferredColorScheme(.light)
        .onTapGesture {
            isFieldFocused = false // Dismiss keyboard globally
        }
    }
}

// Custom Modifier for Input Fields
struct CustomTextFieldStyle: ViewModifier {
    let placeholder: String
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(placeholder)
                .foregroundColor(.gray)
                .font(.headline)
            content
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    ProfileCreation1View()
}







