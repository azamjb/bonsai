//
//  LandingPageView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-01.
//

import SwiftUI

struct LandingPageView: View {
    @State private var textCount: Int = 0
    
    var body: some View {
        ZStack {
            Color.black // Background color
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                // Animated Texts
                ForEach(0..<textCount, id: \.self) { index in
                    Text("bonsai")
                        .font(.custom("San Francisco", size: 90).weight(index == 4 ? .bold : .regular))
                        .foregroundColor(index == 5
                                         ? Color(red: 0.33, green: 1, blue: 0) // Green for the 6th text
                                         : .white)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                
                // Header below the green text
                if textCount > 5 {
                    Text("Your time. Your purpose.")
                        .font(.custom("San Francisco", size: 24).weight(.semibold))
                        .foregroundColor(Color(red: 0.33, green: 1, blue: 0))
                        .transition(.opacity)
                }
            }
            .padding()
            .onAppear {
                animateTextAppearance()
            }
        }
    }
    
    private func animateTextAppearance() {
        for i in 0...5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    textCount = i + 1
                }
            }
        }
    }
}
                
#Preview {
    LandingPageView()
}
