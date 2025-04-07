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
                
                
                Text("In a world that often feels fast-paced and disconnected, small acts of kindness can have a surprisingly powerful impact. Whether it's holding the door open for someone, offering a genuine compliment, or simply smiling at a stranger, these little gestures can uplift others and foster a sense of community. Unlike grand acts of charity, everyday kindness doesn’t require wealth or extensive effort — just intention and empathy.")
                    .padding(.bottom, 10)
                
                Text("Research shows that kindness not only benefits the receiver but also improves the well-being of the person giving it. Acts of kindness can reduce stress, increase happiness, and even improve physical health. In this way, kindness becomes contagious; when someone experiences a kind act, they’re more likely to pay it forward.")
                    .padding(.bottom, 10)
                
                Text("In times of crisis or uncertainty, kindness reminds us of our shared humanity. While it may not solve the world's problems, it plants the seeds for a more compassionate society. And often, it’s the smallest acts that leave the biggest impact.")
                
                
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
