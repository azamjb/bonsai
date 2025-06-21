//
//  ContentView.swift
//  bonsai
//
//  Created by Azam Jawad on 2024-11-28.
//
import SwiftUI
import ManagedSettings

struct ContentView: View {
    
    var AccountabilityPartner = ""
    let accountApi = AccountApi()
    let smsApi = SMSApi()
    @State private var tabSelection = 1
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    @EnvironmentObject var notificationHandler: NotificationHandler
    @StateObject var screenTime = ScreenTimeService()
    @AppStorage("invitedAccountabilityPartner") private var invitedAccountabilityPartnerStorage: Bool = false
    @AppStorage("hasAccountabilityPartner") private var hasPartnerStorage: Bool = false
    

    var body: some View {
        VStack(spacing: 0) {
            // Main content views
            ZStack {
                switch tabSelection {
                case 1:
                    NavigationStack {
                        BoundaryViewerView(tabSelection: $tabSelection)
                    }
                case 2:
                    NavigationStack {
                        ActivityReportView(tabSelection: $tabSelection)
                    }
                case 3:
                    NavigationStack {
                        ProfileView(viewModel: viewModel)
                    }
                default:
                    Text("Unknown Tab")
                }
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selectedTab: $tabSelection)
        }
        .onAppear { // Removing accountability partner locally if it has been removed from the database, check is made every time the app is opened
            Task {
                do {
                    
                    
                    let hasPartner = UserDefaults.standard.bool(forKey: "hasAccountabilityPartner")
                    
                    if hasPartner {
                        
                        let SMSInvite = SMSInvite(
                            number: viewModel.userProfile.phoneNumber ?? "",
                            username: viewModel.userProfile.name ?? "",
                            accountabilityPartnerName: viewModel.accountabilityPartner.name ?? "", code: ""
                        )
                        
                        let idString = UserDefaults.standard.string(forKey: ProfileKey.id.rawValue)
                        let request = checkAccountabilityPartner(Id: idString ?? "")
                        let phoneNumber = try await accountApi.retrieveAccountabilityPartner(request: request)
                        
                        if phoneNumber == "" {
                            
                            viewModel.accountabilityPartner.name = nil
                            viewModel.accountabilityPartner.phoneNumber = nil
                            screenTime.clearAllRestrictions()
                            screenTime.boundariesSet.removeAll()
                            UserDefaults.standard.set(false, forKey: "hasAccountabilityPartner")
                            UserDefaults.standard.set(false, forKey: "invitedAccountabilityPartner")
                            
                            try await smsApi.SelfRemovalNotif(request: SMSInvite)
                            
                        }

                    }
                    

                } catch {
                    print("Failed to retrieve accountability partner: \(error)")
                }
            }
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $notificationHandler.showExtensionRequest) {
            BoundaryExtensionRequestView()
        }
    }
}
    

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        VStack(spacing: 0) {
            // Padded separator line
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.gray)
                .padding(.horizontal, 30)

            HStack(spacing: 0) {
                TabBarButton(title: "BOUNDARIES", tag: 1, selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity)
                TabBarButton(title: "B.", tag: 2, selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity)
                TabBarButton(title: "PROFILE", tag: 3, selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 20)
            .padding(.bottom, 35)
            .padding(.horizontal, 30)
        }
        .background(Color(.systemBackground).ignoresSafeArea(edges: .bottom))
    }
}


struct TabBarButton: View {
    let title: String
    let tag: Int
    @Binding var selectedTab: Int

    var body: some View {
        Button(action: {
            selectedTab = tag
        }) {
            Text(title)
                .font(
                    title == "B."
                    ? .system(size: 24, weight: .bold) // Bigger font just for "B."
                    : .system(size: 14, weight: .bold)
                )
                .foregroundColor(selectedTab == tag ? .primary : .gray)
        }
    }
}


