//
//  BoundaryViewerView.swift
//  bonsai
//
//  Created by Brayden O on 2025-03-15.
//

import SwiftUICore
import SwiftUI

struct BoundaryViewerView: View {
    @Binding var tabSelection: Int
    
    @ObservedObject private var viewModel = BoundaryViewerViewModel()
    @EnvironmentObject var screenTime: ScreenTimeService
    @Environment(\.presentationMode) var presentationMode
    
    @State private var showEditScreen: Bool = false
    @State private var showCannotEditAlert: Bool = false
    @AppStorage("hasAccountabilityPartner") var hasAccountabilityPartner: Bool = false
    
    @State private var navigateToProfileCreation4 = false

    var body: some View {
        
            if !hasAccountabilityPartner {
                noAccountabilityPartnerView(hasAccountabilityPartner: $hasAccountabilityPartner)
                    .alert(isPresented: $showCannotEditAlert) {
                        Alert(
                            title: Text("Out of Boundary edits"),
                            message: Text("You've already used your 2 boundary extensions for the week.")
                        )
                    }
            } else {
                Group {
                    if screenTime.boundariesSet.isEmpty {
                        ZStack {
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    UIApplication.shared.dismissKeyboard()
                                }
                                .ignoresSafeArea()

                            VStack {
                                Text("BOUNDARIES")
                                    .bold()
                                    .font(.system(size: 30))
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 20)
                                
                                Spacer()

                                Text("New here? No worries! Let's set your first boundary. 🚀")
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 20)
                                    .padding(.bottom, 50)

                                (
                                    Text("Tap ")
                                    + Text("\"add new boundary\"").bold()
                                    + Text(" to begin making your custom app boundaries and schedules. You're in control – create as many as you want to shape your ideal balance.")
                                )
                                .font(.system(size: 16))
                                .multilineTextAlignment(.center)
                                .padding(.bottom, 30)

                                Text("Hit save and start tracking!")
                                    .font(.system(size: 16))
                                    .multilineTextAlignment(.center)

                                Spacer()

                                buttonContent
                                    .padding(.bottom, 250)
                            }
                            .padding(.horizontal, 30)
                        }
                    } else {
                        ZStack {
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    UIApplication.shared.dismissKeyboard()
                                }
                                .ignoresSafeArea()

                            VStack(spacing: 16) {
                                Text("BOUNDARIES")
                                    .bold()
                                    .font(.system(size: 30))
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 20)

                                if !screenTime.boundariesSet.isEmpty {
                                    List {
                                        ForEach(screenTime.boundariesSet) { boundary in
                                            if !boundary.invisibleBoundary {
                                                BoundaryRow(boundary: boundary)
                                                    .listRowSeparator(.hidden)
                                            }
                                        }
                                    }
                                    .listStyle(PlainListStyle())
                                    .frame(maxHeight: 450)
                                }
                            }
                        }

                        Spacer()

                        buttonContent
                            .padding(.bottom, 30)
                    }
                }
                .alert(isPresented: $showCannotEditAlert) {
                    Alert(
                        title: Text("Out of Boundary edits"),
                        message: Text("You've already used your 2 boundary extensions for the week.")
                    )
                }
                .navigationDestination(isPresented: $showEditScreen) {
                    BoundaryEditorView()
                        .onDisappear {
                            screenTime.setGroupDisplays()
                        }
                }
            }
    }
    
    private var buttonContent: some View {
        VStack {
            BonsaiButtonRegular(buttonText: screenTime.boundariesSet.isEmpty ? "add new boundary" : "edit boundaries") {
                Task {
                    // Add a small delay to allow state to stabilize
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                    DispatchQueue.main.async {
                        showEditScreen = true
                    }
                }
            }
        }
    }
}


private struct BoundaryRow: View {
    let boundary: Boundary
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(boundary.givenName)
                    .font(.system(size: 24, weight: .medium))
                
                HStack {
                    ForEach(Array(Weekday.allCases), id: \.self) { day in
                        DayPin(day: day, boundary: boundary)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                HStack {
                    VStack {
                        Text(String(boundary.hours))
                            .font(.system(size: 46))
                        
                        Text("H")
                            .font(.system(size: 16))
                    }
                    .padding(.trailing, 12)
                    
                    VStack {
                        Text(String(boundary.minutes))
                            .font(.system(size: 46))
                        Text("MINS")
                            .font(.system(size: 16))
                    }
                }
            }
            
        }
        .padding(.horizontal, 35)
        
        HStack(spacing: -5) {
            ForEach(Array(boundary.appTokens), id: \.self) { token in
                Label(token)
                    .labelStyle(.iconOnly)
                    .scaleEffect(1.7)
            }

            ForEach(Array(boundary.webDomainTokens), id: \.self) { token in
                Label(token)
                    .labelStyle(.iconOnly)
                    .scaleEffect(1.2)
            }

            ForEach(Array(boundary.categoryTokens), id: \.self) { token in
                Label(token)
                    .labelStyle(.iconOnly)
                    .scaleEffect(1.2) // For some reason category tokens are slightly larger
            }
        }
        .padding(.horizontal, 35)

        Rectangle()
          .frame(height: 1)
          .padding(.horizontal, 35)
    }
}

private struct DayPin: View {
    let day: Weekday
    let boundary: Boundary
    
    var body: some View {
        Text(day.label)
            .font(.system(size: 12))
            .frame(width: 15, height: 15)
            .background(Color.secondary)
            .cornerRadius(100)
            .opacity(boundary.weekdays.contains(day) ? 0.8 : 0.2)
    }
}

private struct noAccountabilityPartnerView: View {
    @State private var pin: String = ""
    @State private var wrongCodeEntered = false
    @State private var navigateToProfileCreation4 = false
    @State private var triggerSuccess = false // 👈 New
    let smsApi = SMSApi()
    @ObservedObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()
    @AppStorage("invitedAccountabilityPartner") var invitedAccountabilityPartner: Bool = false
    @Binding var hasAccountabilityPartner: Bool

    var body: some View {
        ScrollView {
            VStack {
                Text("You need to have an Accountability Partner in order to use the main features of this app!")
                    .font(.system(size: 19))
                    .padding(.bottom, 35)
                    .padding(.top, 130)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)

                if invitedAccountabilityPartner {
                    Group {
                        Text("We have sent your partner an invite containing a verification code, enter this code below to validate your partner")
                            .font(.system(size: 19))
                            .padding(.bottom, 40)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)

                        PinEntryView(pin: $pin)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 50)

                        Button {
                            handleInviteCodeValidation(pin: pin)
                            pin = ""
                        } label: {
                            Text("validate")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .padding(.vertical, 15)
                                .padding(.horizontal, 80)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(wrongCodeEntered ? Color.red : Color.primary, lineWidth: 1)
                                )
                        }
                        .padding(.bottom, 20)
                    }
                }

                Button(action: {
                    navigateToProfileCreation4 = true
                }) {
                    Text("Send a New Invite")
                        .foregroundColor(.blue)
                        .font(.system(size: 15))
                        .underline()
                        .frame(alignment: .leading)
                }

                Spacer(minLength: 200)
            }
            .padding(.horizontal, 35)
            .background(Color.white.opacity(0.0001))
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationDestination(isPresented: $navigateToProfileCreation4) {
            ProfileCreation4View()
        }
        .onChange(of: triggerSuccess) { _, newValue in
            if newValue {
                hasAccountabilityPartner = true
            }
        }
    }

    @MainActor
    private func handleInviteCodeValidation(pin: String) {
        let inviteCode = UserDefaults.standard.string(forKey: "AccountabilityPartnerInviteCode")
        let accountabilityPartnerPhone = UserDefaults.standard.string(forKey: "tempAccountabilityPartnerNumber") ?? ""
        let accountabilityPartnerName = UserDefaults.standard.string(forKey: "tempAccountabilityPartnerName") ?? ""

        if pin == inviteCode {
            print("CORRECTTTTTT")

            Task {
                await viewModel.saveAccountabilityPartner(
                    name: accountabilityPartnerName,
                    phoneNumber: accountabilityPartnerPhone
                )

                UserDefaults.standard.removeObject(forKey: "tempAccountabilityPartnerNumber")
                UserDefaults.standard.removeObject(forKey: "tempAccountabilityPartnerName")

                // Add a small delay to allow Screen Time service to stabilize
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                DispatchQueue.main.async {
                    triggerSuccess = true
                }
                
                let SMSInvite = SMSInvite(
                    number: viewModel.accountabilityPartner.phoneNumber ?? "",
                    username: viewModel.userProfile.name ?? "",
                    accountabilityPartnerName: viewModel.accountabilityPartner.name ?? "", code: ""
                )
                
                try await smsApi.introduction(request: SMSInvite)
            }
        } else {
            print("wrongggggg")
            wrongCodeEntered = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                wrongCodeEntered = false
            }
        }
    }
}


struct BoundaryViewerView_Previews: PreviewProvider {
    static var previews: some View {
        let selectedTab = Binding.constant(2)
        
        return NavigationView {
            BoundaryViewerView(tabSelection: selectedTab)
                .environmentObject(ScreenTimeService())
        }
    }
}
