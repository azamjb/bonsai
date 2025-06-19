//
//  TermsAndConditionsView.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-03-27.
//

import SwiftUI

struct TermsAndConditionsView: View {
    
    
    var body: some View {
            
        ScrollView {
            
            VStack {
                
                Text("Terms and Conditions")
                    .font(.system(size: 25))
                    .padding(.top, 15)
                    .padding(.bottom, 55)

                Text("Welcome to Bonsai! These Terms and Conditions govern your use of the Bonsai mobile app. By using the app, you agree to be bound by these terms. If you do not agree, please do not use the app.")
                    .padding(.bottom, 10)

                Text("Bonsai helps users manage their screen time through personal tracking and accountability features. You agree to use the app only for its intended purpose and in compliance with applicable laws.")
                    .padding(.bottom, 10)

                Text("Bonsai collects screen time usage data, your name and phone number, and information about your selected accountability partner. This data is only shared with your accountability partner and is never sold to third parties.")
                    .padding(.bottom, 10)

                Text("Bonsai includes optional in-app purchases, such as screen time extensions and premium features. All purchases are processed through Apple and are non-refundable. You must be at least 13 years old to make purchases.")
                    .padding(.bottom, 10)

                Text("By using the accountability partner feature, you agree to share your screen time data with the selected partner. Both users must consent to this data sharing and agree to respect each other's privacy.")
                    .padding(.bottom, 10)

                Text("All content in the app, including code, design, and branding, is the intellectual property of the developer and is protected by copyright and other laws.")
                    .padding(.bottom, 10)

                Text("The app is provided 'as is' with no warranties. We are not responsible for any issues arising from its use, including data loss or tracking errors.")
                    .padding(.bottom, 10)

                Text("We may update these terms periodically. Continued use of the app after updates means you accept the new terms.")
                    .padding(.bottom, 10)

                Text("If you have any questions, please contact us at: your@email.com")
                    .padding(.bottom, 10)

                
                // Replace with actual terms and conditions ^
            }
            .padding(.horizontal, 40)
            
            
        }
        .customBackToolbar()
            
        
    }
}

#Preview{
    TermsAndConditionsView()
}
