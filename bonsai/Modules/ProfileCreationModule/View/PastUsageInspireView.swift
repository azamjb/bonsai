//
//  PastUsageInspireView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-19.
//

import SwiftUI
import DeviceActivity
import FamilyControls

struct PastUsageInspireView: View {
    @State var usageYears: Int = 20
    
    let center = AuthorizationCenter.shared

    
    var body: some View{
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Logo and Header
                    Image("BonsaiLogo_grey")
                    Text("BONSAI")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    Text("Let's Grow Together")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.top, 8)
                    
                    // Progress Indicator
                    ProgressView(value: 0.75)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color.green))
                        .padding(.vertical, 30)
                        
                    
                    VStack(alignment: .center, spacing: 20) {
                        Text("Based on your current\nscreen usage you're set\nto spend: ")
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Text(String(usageYears) + " years")
                            .padding()
                        
                        Text("Take control.")
                            .padding(.bottom, 20)
                        
                        Text("Make the change.")
                            .padding(.bottom, 50)
                        
                        HStack (spacing: 0){
                            Text("Your ")
                            Text("time.  ").bold()
                            Text("Your ")
                            Text("purpose").bold()
                        }

                    }
                    
                    
                    // Move forward button
                    NavigationLink(destination: ProfileCreation2View()) {
                        Text("Let's do it different!")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 220)
                            .background(Color.black)
                            .cornerRadius(39)
                            .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                }
                .padding()
            }
            .background(Color.white.ignoresSafeArea())
        }
        .preferredColorScheme(.light)
        
    }
    
    
}

#Preview{
    PastUsageInspireView()
}
