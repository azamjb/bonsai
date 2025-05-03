//
//  ProfileCreationFinalView.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-03-09.
//

import SwiftUI

struct ProfileCreationFinalView: View {
    @ObservedObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()
    @EnvironmentObject var screenTime: ScreenTimeService
 
    @State private var hobbies: [String] = []
    @State private var accountabilityPartnerName: String = ""
    @State private var accountabilityPartnerPhone: String = ""
    @FocusState private var isFieldFocused: Bool
    @AppStorage("isProfileCreated") private var isProfileCreated = false
    @State private var shouldNavigate = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("YOUR              TIME.")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                    Text("YOUR    PURPOSE.")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    Text("YOUR              TIME.")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                    Text("YOUR    PURPOSE.")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    Text("YOUR              TIME.")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                    Text("YOUR    PURPOSE.")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                }
                Spacer()
                
                Text("You're all set!")
                    .font(.system(size: 15))
                    .padding(.bottom, 10)
                
                Button {
                    isProfileCreated = true
                    Task {
                        // Add a small delay to allow Screen Time service to stabilize
                        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                        DispatchQueue.main.async {
                            shouldNavigate = true
                        }
                    }
                } label: {
                    Text("Begin Journey")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 120)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.primary, lineWidth: 1)
                        )
                }
                
                Spacer()
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $shouldNavigate) {
                ContentView()
            }
            .onAppear() {
                viewModel.fetchUserProfile()
            }
        }
    }
}

#Preview {
    ProfileCreationFinalView()
}
