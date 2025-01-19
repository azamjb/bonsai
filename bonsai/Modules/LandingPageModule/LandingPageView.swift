//
//  LandingPageView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-01.
//

import SwiftUI

struct LandingPageView: View {
    @State private var size = 0.01
    @State private var opacity = 0.5
    
    var body: some View {
        VStack {
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
        .scaleEffect(size)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                size = 0.7
                opacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.8)) {
                size = 0.9
                opacity = 1.0
            }
        }
        .preferredColorScheme(.light)
    }
}
                
#Preview {
    LandingPageView()
}
