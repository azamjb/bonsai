//
//  Educate.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-08.
//

import SwiftUI

struct EducateView: View {
    @StateObject var viewModel: EducateViewModel = EducateViewModel()
    @Environment(\.dismiss) private var dismiss 

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    
                    Text("Welcome To")
                        .font(.headline)
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 60)

                    VStack(spacing: -115) {
                        Text("BO")
                            .font(.system(size: 245, weight: .black))
                            .italic()
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                        
                        Text("NS")
                            .font(.system(size: 245, weight: .black))
                            .italic()
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)

                        Text("AI.")
                            .font(.system(size: 245, weight: .black))
                            .italic()
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    }

                    
                    VStack(alignment: .leading) {
                        
                        Text("FIND YOUR BALANCE")
                            .font(.title2)
                            .padding(.bottom, 5)
                            .fontWeight(.bold)
                        
                        Text("• Pick the apps you want to track")
                            .font(.caption)
                        
                        Text("• Set screen time goals")
                            .font(.caption)
                        
                        Text("• Stay focused and in control")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 5)
                    .padding(.bottom, 160)
                    
                    
                    
                    VStack(alignment: .trailing) {
                        
                        Text("PARTNER WITH PURPOSE")
                            .font(.title2)
                            .padding(.bottom, 5)
                            .fontWeight(.bold)
                        
                        Text("• Choose an Accountability Partner to keep you ontrack")
                            .font(.caption)
                        
                        Text("• When you reach a limit, the Shield appears - time to step away")
                            .font(.caption)
                        
                        Text("• Need more time? Your partner can send a code to grant you access")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 5)
                    .padding(.bottom, 160)
                    
                    
                    
                    VStack(alignment: .leading) {
                        
                        Text("OWN YOUR TIME")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Track. Grow. Balance.")
                            .font(.title3)
                            .padding(.bottom, 5)
                        
                        Text("• Check your dashboard")
                            .font(.caption)
                        
                        Text("• See your progress")
                            .font(.caption)
                        
                        Text("• Create space for what matters")
                            .font(.caption)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 5)
                    .padding(.bottom, 160)
                    
                    
                    
                    

                    Image("tagline")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 270)
                        .padding(.bottom,70)
                        
                    
                    NavigationLink(destination: ProfileCreation1View()) {
                        HStack {
                            Text("Get Started")
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 70)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                    }

                }
                .padding()
            }
            .scrollIndicators(.hidden)
            .preferredColorScheme(.light)
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    EducateView()
}
