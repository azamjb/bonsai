//
//  InspireView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-08.
//

import SwiftUI

struct InspireView: View {
    @State private var isInspired = false
    
    var body: some View {
        if isInspired {
            EducateView()
        } else {
            VStack {
                Text("Inspire Page")
                    .font(.title)
                    .padding(.bottom, 20)
                
                Button(action: signIn) {
                    HStack {
                        Image(systemName: "arrow.up")
                        Text("I'm Inspired")
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
        isInspired = true
    }
}


                
#Preview {
    InspireView()
}
