//
//  LandingPageView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-01.
//

import SwiftUI

struct LandingPageView: View {
    @State private var isActive = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    var body: some View {
        if isActive {
            InspireView()
        } else {
            VStack {
                VStack{
                    Image("Bonsai_Splash")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    Text("Bonsai.")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.top, 20)
                }
                .foregroundColor(.white)
                .scaleEffect(size)
                .opacity(opacity)
                .onAppear{
                    withAnimation(.easeIn(duration: 1.2)){
                        self.size = 0.9
                        self.opacity = 1.0
                    }
                }
            }
            .preferredColorScheme(.light)
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    self.isActive = true
                }
            }
        }
    }
}
                
#Preview {
    LandingPageView()
}
