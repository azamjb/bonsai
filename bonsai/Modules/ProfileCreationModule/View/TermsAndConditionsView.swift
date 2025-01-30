//
//  TermsAndConditionsView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import SwiftUI

struct TermsAndConditionsView: View {
    @ObservedObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("Please accept our Terms and Conditions")
                Button("Test") {
                    testProfileService()
                }
                NavigationLink(destination: PastUsageInspireView()) {
                    Text("Accept")
                        .foregroundColor(.white) // White text and icon
                        .padding() // Padding inside the button
                        .frame(maxWidth: .infinity) // Full-width button
                        .background(Color.black) // Black background
                        .cornerRadius(12) // Rounded corners
                }
            }
        }
        
    }
    func testProfileService() {
    }
    
}

#Preview {
    TermsAndConditionsView()
}
