//
//  WhatIsAccounabilityPartnerView.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-03-09.
//

import SwiftUI

struct WhatIsKoiMethodView: View {
    
    @Environment(\.presentationMode) var presentationMode // To handle back navigation
    @State private var hobbies: [String] = []
    @State private var accountabilityPartnerName: String = ""
    @State private var accountabilityPartnerPhone: String = ""

    @FocusState private var isFieldFocused: Bool
    @AppStorage("isProfileCreated") private var isProfileCreated = false
    
   
    var body: some View {
        NavigationStack{
                VStack {
                    
                    Spacer()
                    
                    Text("KOI METHOD")
                        .font(.title)
                        .foregroundColor(.primary)
                    
                  
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        
                        Text("What is the KOI method?")
                            .fontWeight(.bold)
                        
                        Text("The KOI method combines 3 psychology principles: ")
                        
                       
                                
                        
                    }
                            
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        
                        Text("How does it work with Bonsai?")
                            .fontWeight(.bold)
                        
                        Text("When you hit your boundary time limit, you can send them a code—if they share it with you, you’ll unlock 30 more minutes.")
                        
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
    WhatIsKoiMethodView()
}
