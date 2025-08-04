//
//  PrivacyPolicyView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-08-04.
//

import SwiftUI

struct PrivacyPolicyView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Text
            Text("Privacy Policy")
                .font(.system(size: 25, weight: .semibold))
                .padding(.vertical, 20)
            
            // Divider
            Divider()
            
            // Reusable HTML component to display the policy
            // It will look for "PrivacyPolicy.html" in your project.
            HTMLVisualizer(fileName: "PrivacyPolicy")
        }
        .padding(.horizontal) // Add some horizontal padding to the VStack
        .navigationBarTitleDisplayMode(.inline) // Ensures the title doesn't take up too much space
        .customBackToolbar()
    }
}

#Preview {
    // Wrap in a NavigationView for a more realistic preview
    NavigationView {
        PrivacyPolicyView()
    }
}
