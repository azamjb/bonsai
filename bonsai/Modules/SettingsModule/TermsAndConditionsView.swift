//
//  TermsAndConditionsView.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-03-27.
//

import SwiftUI

struct TermsAndConditionsView: View {
    
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Privacy Policy")
                .font(.system(size: 25, weight: .semibold))
                .padding(.vertical, 20)
            
            Divider()
            
            // It will look for "TermsAndConditions.html" in bonsai.project.
            HTMLVisualizer(fileName: "TermsAndConditions")
        }
        .padding(.horizontal)
        .navigationBarTitleDisplayMode(.inline)
        .customBackToolbar()
    }
}

#Preview{
    // Wrapped in a NavigationView for a more realistic preview
    NavigationView {
        TermsAndConditionsView()
    }
}
