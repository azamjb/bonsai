//
//  PrivacyPolicyView.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-03-27.
//

import SwiftUI

struct PrivacyPolicyView: View {
    
    
    var body: some View {
            
        ScrollView {
            
            VStack {
                
                Text("Privacy Policy")
                    .font(.system(size: 25))
                    .padding(.top, 15)
                    .padding(.bottom, 55)

                Text("Your privacy is important to us. This Privacy Policy outlines how Bonsai collects, uses, and protects your personal information.")
                    .padding(.bottom, 10)

                Text("We collect the following data: your name, phone number, screen time usage, and information about your selected accountability partner. This data is necessary for core app functionality.")
                    .padding(.bottom, 10)

                Text("Your screen time data is only shared with the accountability partner you choose. You and your partner must mutually agree to participate. We do not share your data with third parties.")
                    .padding(.bottom, 10)

                Text("We store data securely and use reasonable safeguards to protect your information. However, no system is 100% secure, and we cannot guarantee absolute security.")
                    .padding(.bottom, 10)

                Text("In-app purchases are handled through Apple and we do not collect or store your payment information.")
                    .padding(.bottom, 10)

                Text("We do not use your data for advertising or marketing purposes. All data is used solely to provide and improve the Bonsai experience.")
                    .padding(.bottom, 10)

                Text("You may request deletion of your personal data at any time by contacting us at: your@email.com. Upon request, your data will be permanently deleted from our servers.")
                    .padding(.bottom, 10)

                Text("This Privacy Policy may be updated occasionally. Continued use of Bonsai after changes means you accept the updated policy.")
                    .padding(.bottom, 10)

                Text("If you have any questions about this Privacy Policy, please contact us at: your@email.com")
                    .padding(.bottom, 10)

                
                
                // Replace with actual privacy policy ^
            }
            .padding(.horizontal, 40)
            
            
        }
        .customBackToolbar()
            
        
    }
}

#Preview{
    PrivacyPolicyView()
}
