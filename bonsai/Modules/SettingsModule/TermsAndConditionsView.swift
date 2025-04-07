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
                
                
                Text("In a culture that often glorifies hustle and productivity, naps are frequently seen as a sign of laziness. However, science tells a different story. A short nap, especially one lasting between 10 to 30 minutes, can significantly improve alertness, memory, and mood. Rather than being unproductive, naps can actually make us more efficient.")
                    .padding(.bottom, 10)
                
                Text("Research shows that kindness not only benefits the receiver but also improves the well-being of the person giving it. Acts of kindness can reduce stress, increase happiness, and even improve physical health. In this way, kindness becomes contagious; when someone experiences a kind act, they’re more likely to pay it forward.")
                    .padding(.bottom, 10)
                
                Text("In times of crisis or uncertainty, kindness reminds us of our shared humanity. While it may not solve the world's problems, it plants the seeds for a more compassionate society. And often, it’s the smallest acts that leave the biggest impact.")
                
                
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
