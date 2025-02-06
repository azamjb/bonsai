//
//  Educate.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-08.
//

import SwiftUI

struct EducateView: View {
    @StateObject var viewModel: EducateViewModel = EducateViewModel()
    @Environment(\.dismiss) private var dismiss // Environment property for dismissing the view

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    
                    Text("Welcome To")
                        .font(.headline)
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 60)

                    Text("BONSAI.")
                        .font(.system(size: 240, weight: .black))
                        .italic()
                        .lineSpacing(0)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 160)
                    
                    VStack(alignment: .leading) {
                        
                        Text("Find Your Balance")
                            .font(.title2)
                            .padding(.bottom, 5)
                        
                        Text("• Choose the apps you want to track")
                            .font(.caption)
                        
                        Text("• Set daily screen time limits")
                            .font(.caption)
                        
                        Text("• Take control of your time")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 5)
                    .padding(.bottom, 160)
                    
                    
                    
                    VStack(alignment: .trailing) {
                        
                        Text("Partner with a Purpose")
                            .font(.title2)
                            .padding(.bottom, 5)
                        
                        Text("• Choose your accountability partner")
                            .font(.caption)
                        
                        Text("• your partner can grant you extra time")
                            .font(.caption)
                        
                        Text("• Don't want to reach out? be prepared to pay")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 5)
                    .padding(.bottom, 160)
                    
                    
                    
                    VStack(alignment: .leading) {
                        
                        Text("Own Your Time")
                            .font(.title2)
                            .padding(.bottom, 5)
                        
                        Text("• Apps will be blocked once you hit your time limit")
                            .font(.caption)
                        
                        Text("• Accountability partners help you stick to your limits.")
                            .font(.caption)
                        
                        Text("• Use your time wisely and productively")
                            .font(.caption)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 5)
                    .padding(.bottom, 160)
                    
                    
                    
                    VStack(alignment: .trailing) {
                        
                        Text("Track. Grow. Balance.")
                            .font(.title2)
                            .padding(.bottom, 5)
                        
                        Text("• View detailed analytics of your screen time")
                            .font(.caption)
                        
                        Text("• Monitor your progress toward your goals")
                            .font(.caption)
                        
                        Text("• Achieve balance in your digital life")
                            .font(.caption)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 5)
                    .padding(.bottom, 160)

                    Image("tagline")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 230)
                        .padding(.bottom,100)
                        
                    
                    NavigationLink(destination: ProfileCreation1View()) {
                        HStack {
                            Text("Get Started")
                                .font(.system(size: 18))
                                .foregroundStyle(.black)

                            Image(systemName: "arrowshape.right.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(.black)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 40)
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
