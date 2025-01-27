//
//  InspireView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-08.
//

import SwiftUI

struct InspireView: View {
    @StateObject var viewModel: InspireViewModel = InspireViewModel()    
    
    
    var body: some View {
        NavigationStack{
            VStack {
                Text("Inspire Page")
                    .font(.title)
                    .padding(.bottom, 20)
                
                NavigationLink(destination: EducateView()) {
                    Text("I'm Inspired. Scary phone stuff!!")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(12)
                }
            }
            .padding()
            .preferredColorScheme(.light)
        }
        
    }
}


#Preview {
    let inspireViewModel = InspireViewModel()
    InspireView(viewModel: inspireViewModel)
}
