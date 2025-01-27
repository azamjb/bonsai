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
        NavigationStack{
            VStack {
                Text("Educate Page")
                    .font(.title)
                    .padding(.bottom, 20)
                
                NavigationLink(destination: ProfileCreation1View()) {
                    Text("I'm Inspired. Scary phone stuff!!")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(12)
                }
                
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(12)
            }
            .padding()
            .preferredColorScheme(.light)
        }
    }
}

#Preview {
    EducateView()
}
