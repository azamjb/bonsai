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
                    .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Name Text Box
                    Text("Name")
                        .foregroundColor(.gray) // Light grey title
                        .font(.headline)
                        .padding( 10)
                    TextField("Enter your accountability partner's name", text: $accountabilityPartnerName)
                        .padding()
                        .background(Color.gray.opacity(0.2)) // Light grey background
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        .focused($isFieldFocused)
                    
                    // Phone Number Text Box
                    Text("Phone Number")
                        .foregroundColor(.gray) // Light grey title
                        .font(.headline)
                    TextField("Accountability Parnter Phone Number", text: $accountabilityPartnerPhone)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .keyboardType(.phonePad)
                        .foregroundColor(.black)
                        .focused($isFieldFocused)
                        
                    
                    Spacer()
                }
                NavigationLink(destination: ContentView()) {
                    HStack {
                        Text("Add a partner")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .cornerRadius(12)
                }
                .simultaneousGesture(TapGesture().onEnded {
                    viewModel.saveAccountabilityPartner(name: accountabilityPartnerName, phoneNumber: accountabilityPartnerPhone)
                    isProfileCreated = true
                })
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
