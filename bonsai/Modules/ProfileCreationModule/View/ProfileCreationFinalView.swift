//
//  ProfileCreationFinalView.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-03-09.
//

import SwiftUI

struct ProfileCreationFinalView: View {
    @ObservedObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()
    @Environment(\.presentationMode) var presentationMode 
    @State private var hobbies: [String] = []
    @State private var accountabilityPartnerName: String = ""
    @State private var accountabilityPartnerPhone: String = ""
    @FocusState private var isFieldFocused: Bool
    @AppStorage("isProfileCreated") private var isProfileCreated = false
    
   
    var body: some View {
        NavigationStack{
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
                    
                    NavigationLink(destination: ContentView()) {
                        Text("Begin Journey")
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.primary, lineWidth: 1)
                            )
                            .simultaneousGesture(TapGesture().onEnded {
                                
                                isProfileCreated = true
                            })
                    }
                    
                    Spacer()
                    
                    
                    
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16))
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
        }
        .onAppear() {
            viewModel.fetchUserProfile()
        }
        
        
    }
    
    
}


#Preview {
    ProfileCreationFinalView()
}
