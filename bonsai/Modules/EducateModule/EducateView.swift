//
//  Educate.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-08.
//

import SwiftUI

struct EducateView: View {
    @State private var isEducated = false
    
    var body: some View {
        if isEducated {
            ProfileCreationView()
        } else {
            VStack {
                Text("Educate Page")
                    .font(.title)
                    .padding(.bottom, 20)
                
                Button(action: signIn) {
                    HStack {
                        Image(systemName: "arrow.up")
                        Text("Let's Get Started")
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

                
        }
    }
    func signIn(){
        isEducated = true
    }
}

#Preview {
    EducateView()
}
