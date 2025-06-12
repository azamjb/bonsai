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
                    
                    VStack(spacing: -33) {
                        
                        Text("Welcome To")
                            .font(.system(size: 45, weight: .bold))
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
                        .padding(.bottom, 50)
                        
                    }

                    
                    VStack(alignment: .leading) {
                        
                        Text("FIND YOUR BALANCE")
                            .font(.title2)
                            .padding(.bottom, 5)
                            .fontWeight(.bold)
                        
                        Text("Pick the apps you want to track")
                            .font(.caption)
                            .padding(.bottom, 2)
                        
                        Text("Set screen time goals")
                            .font(.caption)
                            .padding(.bottom, 2)
                        
                        Text("Stay focused and in control")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 5)
                    .padding(.bottom, 120)
                    
                    
                    
                    VStack(alignment: .trailing) {
                        
                        Text("PARTNER WITH PURPOSE")
                            .font(.title2)
                            .padding(.bottom, 5)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        
                        Text("Choose a partner to keep you on track")
                            .font(.caption)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(.bottom, 2)
                        
                        Text("When you reach a limit, your apps get blocked")
                            .font(.caption)
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .padding(.bottom, 2)
                        
                        Text("Need more time? Your partner can grant you access")
                            .font(.caption)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 5)
                    .padding(.bottom, 120)

                    
                    
                    VStack(alignment: .leading) {
                        
                        Text("OWN YOUR TIME")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                        
                        
                        Text("Check your dashboard")
                            .font(.caption)
                            .padding(.bottom, 2)
                        
                        Text("See your progress")
                            .font(.caption)
                            .padding(.bottom, 2)
                        
                        Text("Create space for what matters")
                            .font(.caption)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 5)
                    .padding(.bottom, 120)
                    
                    
                    NavigationLink(destination: ProfileCreation1View()) {
                        HStack {
                            Text("Get Started")
                                .font(.system(size: 18))
                                .foregroundColor(.black)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 90)
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
