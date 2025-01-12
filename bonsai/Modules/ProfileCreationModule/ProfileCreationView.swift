//
//  ProfileCreationView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-08.
//

import SwiftUI
import iPhoneNumberField

struct ProfileCreationView: View {
    @State private var presentContentView = false
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    var body: some View {
        if presentContentView {
            ContentView()
        } else {
            VStack {
                Image("BonsaiLogo_grey")
                Text("BONSAI")
                    .font(.system(size: 32, weight: .bold))
                .foregroundColor(.black)
                Text("Let's Grow Together")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.top, 16.0)
                    .padding(.bottom, 14.0)
                    .shadow(radius:30)
                
                ZStack (alignment: .leading){
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 310, height: 8)
                      .background(Color(red: 0.85, green: 0.85, blue: 0.85))
                      .cornerRadius(5)
                    
                    Rectangle()
                      .foregroundColor(.clear)
                      .frame(width: 162, height: 8)
                      .background(
                        LinearGradient(
                          stops: [
                            Gradient.Stop(color: Color(red: 0.1, green: 0.69, blue: 0.18), location: 0.00),
                            Gradient.Stop(color: Color(red: 0.56, green: 0.78, blue: 0.59), location: 1.00),
                          ],
                          startPoint: UnitPoint(x: 0, y: 0.5),
                          endPoint: UnitPoint(x: 1, y: 0.5)
                        )
                      )
                      .cornerRadius(5)
                }
                .padding(.bottom, 65)
                
                VStack(alignment: .leading, spacing: 20) {
                            // Name Text Box
                            Text("Name")
                                .foregroundColor(.gray) // Light grey title
                                .font(.headline)
                            TextField("Enter your name", text: $name)
                                .padding()
                                .background(Color.gray.opacity(0.2)) // Light grey background
                                .cornerRadius(8)
                                .foregroundColor(.black)
                            
                            // Phone Number Text Box
                            Text("Phone Number")
                                .foregroundColor(.gray) // Light grey title
                                .font(.headline)
                            iPhoneNumberField("Phone Number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                                .padding()
                                .background(Color.gray.opacity(0.2)) // Light grey background
                                .cornerRadius(8)
                                .keyboardType(.phonePad) // Set to phone number input
                                .foregroundColor(.black)
                            
                            Spacer()
                        }
                        .padding()
                
                Button(action: CreateProfile) {
                    HStack {
                        Image(systemName: "arrow.up")
                        Text("Create Profile")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white) // White text and icon
                    .padding() // Padding inside the button
                    .frame(maxWidth: .infinity) // Full-width button
                    .background(Color.black) // Black background
                    .cornerRadius(12) // Rounded corners
                }
                .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5) // Shadow with gray color
                
            }
            .padding()
            .preferredColorScheme(.light)
            
            Spacer()

                
        }
    }

    
    func CreateProfile(){
        // create the local user profile
        // switch to content view page
        presentContentView = true
    }
}

#Preview {
    ProfileCreationView()
}
