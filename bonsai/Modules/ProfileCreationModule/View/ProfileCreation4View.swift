import SwiftUI

struct ProfileCreation4View: View {


    @ObservedObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()

    @ObservedObject var AccountabilityPartnerviewModel: AccountabilityPartnerViewModel = AccountabilityPartnerViewModel()
    @State private var hobbies: [String] = []
    @Environment(\.dismiss) var dismiss
    @State private var navigateToFinal = false
    @State private var accountabilityPartnerName: String = ""
    @State private var accountabilityPartnerPhone: String = ""
    @State private var isPhoneNumberInvalid: Bool = false
    @FocusState private var isFieldFocused: Bool
    @AppStorage("isProfileCreated") private var isProfileCreated = false

    var body: some View {
        NavigationStack {
            ZStack {
                
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        hideKeyboard()
                    }
                
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
                    .padding(.bottom, 20)

                    VStack(spacing: 10) {
                        Group {
                            BonsaiTextField(binding: $accountabilityPartnerName, title: "Enter Partner Name")
                            BonsaiPhoneNumberField(binding: $accountabilityPartnerPhone, title: "Enter Partner Phone Number") { value in
                                print(value)
                                isPhoneNumberInvalid = viewModel.userProfile.phoneNumber == $accountabilityPartnerPhone.wrappedValue
                            }
                            
                            if isPhoneNumberInvalid {
                                Text("Please choose a different phone number than your own.")
                                    .foregroundColor(.red)
                            }
                        }
                        .focused($isFieldFocused)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)

                    
                    Button(action: {
                                if isProfileCreated {
                                    dismiss() // just go back
                                } else {
                                    // Navigate to ProfileCreationFinalView
                                    navigateToFinal = true
                                }
                            }) {
                                Text("Send Invite")
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 120)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.primary, lineWidth: 1)
                                    )
                            }
                            .background(
                                NavigationLink("", destination: ProfileCreationFinalView(), isActive: $navigateToFinal)
                                    .hidden()
                            )
                            .simultaneousGesture(TapGesture().onEnded {
                        Task {
                            let userName = UserDefaults.standard.string(forKey: ProfileKey.name.rawValue)
                            await AccountabilityPartnerviewModel.sendInvite(phoneNumber: accountabilityPartnerPhone, userName: userName ?? "", accountabilityPartnerName: accountabilityPartnerName)

                            UserDefaults.standard.set(false, forKey: "hasAccountabilityPartner") // set to false until accountability partner accepts invite (sends request code)
                            UserDefaults.standard.set(true, forKey: "invitedAccountabilityPartner") // whether a user has a current pending invite for an accountability partner
                            UserDefaults.standard.set(accountabilityPartnerPhone, forKey: "tempAccountabilityPartnerNumber")
                            UserDefaults.standard.set(accountabilityPartnerName, forKey: "tempAccountabilityPartnerName")
                        }
                    }) .padding(.horizontal, 20)
                           Spacer()
                           Spacer()


                    Button(action: {
                                if isProfileCreated {
                                    dismiss() // just go back
                                } else {
                                    // Navigate to ProfileCreationFinalView
                                    navigateToFinal = true
                                }
                            }) {
                                Text("set up later")
                                    .foregroundColor(.blue)
                                    .underline()
                                    .frame(alignment: .leading)
                            }
                    Spacer()
                    Spacer()
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .navigationBarBackButtonHidden(true)
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
