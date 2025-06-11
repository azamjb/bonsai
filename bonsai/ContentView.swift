//
//  ContentView.swift
//  bonsai
//
//  Created by Azam Jawad on 2024-11-28.
//
import SwiftUI
import ManagedSettings

struct ContentView: View {
    @State private var tabSelection = 1
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    @EnvironmentObject var notificationHandler: NotificationHandler

    var body: some View {
        VStack(spacing: 0) {
            // Main content views
            ZStack {
                switch tabSelection {
                case 1:
                    NavigationStack {
                        ActivityReportView(tabSelection: $tabSelection)
                    }
                case 2:
                    NavigationStack {
                        BoundaryViewerView(tabSelection: $tabSelection)
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
                TabBarButton(title: "PROFILE", tag: 3, selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity)
                TabBarButton(title: "B.", tag: 1, selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity)
                TabBarButton(title: "BOUNDARIES", tag: 2, selectedTab: $selectedTab)
                    .frame(maxWidth: .infinity)
            }
            .padding(.top, 20)
            .padding(.bottom, 40)
            .padding(.horizontal, 30)
        }
        .background(Color.white.ignoresSafeArea(edges: .bottom))
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
                .foregroundColor(selectedTab == tag ? .black : .gray)
        }
    }
}


