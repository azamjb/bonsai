//
//  WhatIsAccounabilityPartnerView.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-03-09.
//

import SwiftUI

struct WhatIsAccountabilityPartnerView: View {
    
    @Environment(\.presentationMode) var presentationMode 
    @State private var hobbies: [String] = []
    @State private var accountabilityPartnerName: String = ""
    @State private var accountabilityPartnerPhone: String = ""

    @FocusState private var isFieldFocused: Bool
    @AppStorage("isProfileCreated") private var isProfileCreated = false
    
   
    var body: some View {
        NavigationStack{
                VStack {
                    
                    Spacer()
                    
                    Text("Accountability Partner")
                        .font(.title)
                        .foregroundColor(.primary)
                    
                  
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        
                        Text("What is an Accountability Partner?")
                            .fontWeight(.bold)
                        
                        Text("Someone who helps you stay on track with your time limits and goals, using the ")
                        
                        NavigationLink(destination: WhatIsKoiMethodView()) {
                            Text("Koi method")
                                .foregroundColor(.blue)
                                .underline()
                                .frame(alignment: .leading)
                        }
                                
                        
                    }
                            
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        
                        Text("How does it work?")
                            .fontWeight(.bold)
                        
                        Text("When you hit your boundary time limit, you can trigger  a request to your partner. They will be be given a 6-digit code, if they share it with you, you’ll unlock 30 more minutes.")
                        
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        
                        Text("How do I set it up?")
                            .fontWeight(.bold)
                        
                        Text("Simply enter their name and number; they’ll confirm via text to opt in, and your partnership is set!")
                        
                    }
                    
                    Spacer()
                    
                    NavigationLink(destination: ProfileCreation4View()) {
                        Text("set up partner")
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 100)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.primary, lineWidth: 1)
                            )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
        }
        .padding(.horizontal, 20)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
}


#Preview {
    WhatIsAccountabilityPartnerView()
}
