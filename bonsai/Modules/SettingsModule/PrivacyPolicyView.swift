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
            Text("Privacy Policy")
                .font(.system(size: 25, weight: .semibold))
                .padding(.vertical, 20)
            
            Divider()
            
            // It will look for "PrivacyPolicy.html" in your project.
            HTMLVisualizer(fileName: "PrivacyPolicy")
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .customBackToolbar()
    }
}

#Preview {
    // Wrapped in a NavigationView for a more realistic preview
    NavigationView {
        PrivacyPolicyView()
    }
}
