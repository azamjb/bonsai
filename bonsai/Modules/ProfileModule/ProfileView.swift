//
//  ProfileView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import SwiftUI

struct ProfileView: View {

    let accountApi = AccountApi()
    let smsApi = SMSApi()
    @StateObject var screenTime = ScreenTimeService()

    @EnvironmentObject var quoteViewModel: QuoteViewModel
    @State private var showRemoveConfirmation = false
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    @State private var showPartnerSection: Bool = false
    private let removePartnerMessage = "Are you sure you want to remove your accountability partner? You will not be able to use many features of the application until you add a new one"
    @AppStorage("invitedAccountabilityPartner") private var invitedAccountabilityPartnerStorage: Bool = false
    @AppStorage("hasAccountabilityPartner") private var hasPartnerStorage: Bool = false
    @State private var shouldSetHasPartnerFalse: Bool = false
    @State private var invitedPartnerShouldBeFalse: Bool = false



    var body: some View {

            ScrollView {
                VStack {

                    NavigationLink(destination: SettingsView()) {
                        HStack {
                            Spacer()
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 25))
                                .foregroundColor(.primary)
                                .padding(.vertical, 5)
                        }
                        .padding(.horizontal, 18)
                    }

                    Group {
                        HStack {
                            Text(viewModel.userProfile.name ?? "unable to find name")
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                                .font(.system(size: 28))

                            Spacer()

                            VStack {
                                Spacer()
                                Text(viewModel.currentMonth)
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 20))
                                Spacer()
                            }
                        }
                        .padding(.bottom, 15)
                    }
                    .padding(.horizontal, 18)
                    .frame(maxWidth: .infinity, alignment: .leading)

                    HStack {
                        Image("design")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 330, height: 330)
                            .padding(.bottom, 20)
                    }

//                    Group {
//                        HStack {
//                            Text("PHONE")
//                                .fontWeight(.bold)
//
//                            Spacer()
//                            Text(viewModel.phoneNumberFormatter.string(for: viewModel.userProfile.phoneNumber) ?? "")
//                                .font(.system(size: 14))
//                        }
//                        .padding(.top, 20)
//                        .padding(.bottom, 20)
//                    }
//                    .padding(.horizontal, 18)
//                    .frame(maxWidth: .infinity, alignment: .leading)

//                    NavigationLink(destination: ProfileEditView(viewModel: viewModel)) {
//                        HStack {
//                            Text("edit profile")
//                                .font(.system(size: 15))
//                                .foregroundColor(.primary)
//                                .padding(.vertical, 5)
//                                .padding(.horizontal, 20)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 20)
//                                        .stroke(Color.primary, lineWidth: 1)
//                                )
//                        }
//                    }
//                    .padding(.bottom, 20)
//                    .padding(.top, 10)

//                    Divider()
//                        .frame(height: 1)
//                        .background(Color.primary)
//                        .padding(.horizontal, 15)

                    Text("BALANCE STATS")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 15)
                        .padding(.bottom, 20)
                        .padding(.horizontal, 18)
                        .font(.system(size: 17))

                    HStack {

                            VStack(alignment: .leading) {
                                Text(String(viewModel.getCurrentStreakDays()))
                                    .font(.system(size: 40))
                                Text("CURRENT")
                                    .font(.system(size: 10))
                                Text("STREAK")
                                    .font(.system(size: 10))
                            }

                            Spacer()

                            VStack(alignment: .leading) {
                                Text(String(viewModel.getLongestStreakDays()))
                                    .font(.system(size: 40))
                                Text("BEST")
                                    .font(.system(size: 10))
                                Text("STREAK")
                                    .font(.system(size: 10))
                            }

                            Spacer()

                            VStack(alignment: .leading) {
                                Text(String(viewModel.getExtensionRequestsCount()))
                                    .font(.system(size: 40))
                                Text("EXTENSIONS")
                                    .font(.system(size: 10))
                                Text("REQUESTED")
                                    .font(.system(size: 10))
                            }

                            Spacer()

                            VStack(alignment: .leading) {
                                Text(String(viewModel.getTotalDaysWithoutExtension()))
                                    .font(.system(size: 40))
                                Text("DAYS")
                                    .font(.system(size: 10))
                                Text("BALANCED")
                                    .font(.system(size: 10))
                            }

                        }
                        .padding(.horizontal, 18)

                    Divider()
                        .frame(height: 1)
                        .background(Color.primary)
                        .padding(.horizontal, 15)
                        .padding(.top, 25)

                    Spacer()


                    if showPartnerSection {
                        
                        Text("ACCOUNTABILITY PARTNER")
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 17))
                            .padding(.horizontal, 18)
                            .padding(.bottom, 20)
                            .padding(.top, 25)
                        
                        
                        HStack(alignment: .center) {

                            VStack(alignment: .leading, spacing: 8) {

                                Text(viewModel.accountabilityPartner.name ?? "can't fetch name")
                                    .fontWeight(.bold)

                                Text(viewModel.phoneNumberFormatter.string(for: viewModel.accountabilityPartner.phoneNumber) ?? "")
                                    .font(.system(size: 14))
                            }
                            .padding(.horizontal, 18)
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack {

                                Button(action: {
                                    showRemoveConfirmation = true // show alert first
                                }) {
                                    Text("remove")
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                        .padding(.vertical, 8)
                                        .padding(.horizontal, 25)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(Color.primary, lineWidth: 1)
                                        )
                                }
                                .alert(removePartnerMessage, isPresented: $showRemoveConfirmation) {
                                    Button("Remove", role: .destructive) {
                                        removeAccountabilityPartner()
                                    }
                                    Button("Cancel", role: .cancel) { }
                                }

                            }
                            .padding(.trailing, 18)
                        }
                        .padding(.bottom, 70)
                    }
                    else {
                        Text("No Accountability Partner")
                            .padding(.top, 20)
                            .padding(.bottom, 20)
                    }

                    HStack {
                        Image("tigggg")
                            .resizable()
                            .scaledToFit()
                    }

                    VStack {
                        if let quote = quoteViewModel.quote {
                            Text("\"\(quote.quote)\"")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.custom("Georgia", size: 17))
                            Text("- \(quote.author)")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .font(.custom("Georgia", size: 17))

                        } else {
                            Text("Loading...")
                        }
                        
                    }
                    .padding(.horizontal, 18)
                    .padding(.bottom, 10)
                }
                .padding()
                .navigationBarBackButtonHidden(true)
                .onAppear {
                    viewModel.fetchUserProfile()
                    viewModel.fetchAccountabilityPartner()
                    showPartnerSection = UserDefaults.standard.bool(forKey: "hasAccountabilityPartner")
                }
            }

        .onChange(of: invitedPartnerShouldBeFalse) { newValue in
            if newValue {
                invitedAccountabilityPartnerStorage = false
            }
        }
        .onChange(of: shouldSetHasPartnerFalse) { newValue in
            if newValue {
                hasPartnerStorage = false
            }
        }
    }


    @MainActor
    func removeAccountabilityPartner() {

        Task {

            do {

                let idString = UserDefaults.standard.string(forKey: ProfileKey.id.rawValue)
                let request = AddAccountabilityPartner(
                    AccountabilityPartnerName: "",
                    AccountabilityPartnerPhoneNumber: "",
                    Id: idString ?? ""
                )
                let SMSInvite = SMSInvite(
                    number: viewModel.accountabilityPartner.phoneNumber ?? "",
                    username: viewModel.userProfile.name ?? "",
                    accountabilityPartnerName: viewModel.accountabilityPartner.name ?? "", code: ""
                )

                try await accountApi.addAccountabilityPartner(request: request)

                try await smsApi.removalNotif(request: SMSInvite)

                await MainActor.run {

                    viewModel.accountabilityPartner.phoneNumber = nil
                    viewModel.accountabilityPartner.name = nil
                    screenTime.clearAllRestrictions()
                    screenTime.boundariesSet.removeAll()
                    invitedPartnerShouldBeFalse = true
                    shouldSetHasPartnerFalse = true
                    showPartnerSection = false
                }

            } catch {
                print("Failed to remove accountability partner: \(error)")
            }



        }
    }
    

}

#Preview {
    ProfileView()
}
