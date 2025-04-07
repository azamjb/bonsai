import SwiftUI

struct ProfileCreation4View: View {
    

    @ObservedObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()
    @State private var hobbies: [String] = []
    @State private var accountabilityPartnerName: String = ""
    @State private var accountabilityPartnerPhone: String = ""
    @FocusState private var isFieldFocused: Bool
    @AppStorage("isProfileCreated") private var isProfileCreated = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Let's setup your")
                            .font(.title)
                        
                        Text("Accountability Partner")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        NavigationLink(destination: WhatIsAccountabilityPartnerView()) {
                            Text("What's an accountability partner?")
                                .foregroundColor(.blue)
                                .underline()
                                .frame(alignment: .leading)
                        }
                    }
                    .padding(.bottom, 40)

                    VStack(spacing: 16) {
                        Group {
                            TextField("", text: $accountabilityPartnerName)
                                .modifier(CustomTextFieldStyle(placeholder: "Enter partner name:"))
                                .frame(minHeight: 50)

                            TextField("", text: $accountabilityPartnerPhone)
                                .keyboardType(.phonePad)
                                .modifier(CustomTextFieldStyle(placeholder: "Enter partner phone #:"))
                                .frame(minHeight: 50)
                        }
                        .focused($isFieldFocused)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()

                    NavigationLink(destination: ProfileCreationFinalView()) {
                        Text("Save")
                            .font(.system(size: 15))
                            .foregroundColor(.primary)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 120)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.primary, lineWidth: 1)
                            )
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        Task {
                            await viewModel.saveAccountabilityPartner( // accountability partner saved here
                                name: accountabilityPartnerName,
                                phoneNumber: accountabilityPartnerPhone
                            )
                        }
                    })
                    
                    Spacer()
                    
                    NavigationLink(destination: ProfileCreationFinalView()) {
                        Text("set up later")
                            .foregroundColor(.blue)
                            .underline()
                            .frame(alignment: .leading)
                    }
                    
                    Spacer()
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .customBackToolbar()
            }
            .onTapGesture {
                hideKeyboard()
            }
        }
        .onAppear {
            viewModel.fetchUserProfile()
        }
    }
}



#Preview {
    ProfileCreation4View()
}
