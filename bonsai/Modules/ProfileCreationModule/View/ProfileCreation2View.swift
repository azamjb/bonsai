//
//  ProfileCreation2View.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import SwiftUI

struct ProfileCreation2View: View {
    @ObservedObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()
    @State private var hobbies: [String] = []
    @State private var accountabilityPartnerName: String = ""
    @State private var accountabilityPartnerPhone: String = ""
    @FocusState private var isFieldFocused: Bool
    @AppStorage("isProfileCreated") private var isProfileCreated = false
    
    let systemHobbies = ["Friends", "Family", "Work", "School", "Sports", "Music", "Art", "Reading", "Gaming", "Traveling", "Cooking", "Fitness", "Movies", "Nature", "Writing", "SLEEEEP!"]
    
    var body: some View {
        NavigationStack{
            ScrollView{
                VStack {
                    Text("Welcome, \(viewModel.userProfile.name)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(20)
                    Spacer()
                    Text("Your journey starts now.")
                        .padding(.bottom, 40)
                    
                    Text("What matters most to you? ")
                        .multilineTextAlignment(.center)
                        .padding(10)
                    
                    Text("Choose up to 5 areas to reallocate your time and start living with purpose.")
                        .padding(.bottom, 25)
                        .multilineTextAlignment(.center)
                    
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4),
                        spacing: 16
                    ) {
                        ForEach(systemHobbies, id: \.self) { hobby in
                            hobbyTile(
                                hobby: hobby,
                                isSelected: hobbies.contains(hobby),
                                onTap: {
                                    if hobbies.contains(hobby) {
                                        hobbies.removeAll { $0 == hobby }
                                    } else if hobbies.count < 5 {
                                        hobbies.append(hobby)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                    Text("Selected Hobbies: \(hobbies.joined(separator: ", "))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                    
                    VStack(spacing: 16) {
                        Group {
                            TextField("Enter accountability partner's name", text: $accountabilityPartnerName)
                                .modifier(CustomTextFieldStyle(placeholder: "Name"))
                            TextField("Enter accountability partner's phone number", text: $accountabilityPartnerPhone)
                                .keyboardType(.phonePad)
                                .modifier(CustomTextFieldStyle(placeholder: "Phone Number"))
                        }
                        .focused($isFieldFocused)
                    }
                    .padding()
                    .onTapGesture {
                        isFieldFocused = false // Dismiss keyboard when tapping outside fields
                    }
                    Spacer()
                    NavigationLink(destination: ContentView()) {
                        Text("Get Started")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        Task {
                            await viewModel.saveAccountabilityPartner(name: accountabilityPartnerName, phoneNumber: accountabilityPartnerPhone, hobbies: hobbies)
                        }
                        
                        isProfileCreated = true
                    })
                }
                .padding()
            }
        }
        .onAppear() {
            viewModel.fetchUserProfile()
        }
        
        
    }
    
    func hobbyTile(hobby: String, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.green : Color.gray)
                .frame(width: 80, height: 30)
            Text(hobby)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .onTapGesture {
            onTap()
        }
    }
}


#Preview {
    ProfileCreation2View()
}
