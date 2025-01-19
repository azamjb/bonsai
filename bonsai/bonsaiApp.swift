//
//  bonsaiApp.swift
//  bonsai
//
//  Created by Azam Jawad on YYYY-MM-DD.
//

import SwiftUI

@main
struct bonsaiApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }

}

// Here we can set a way to display splash screen then profile creation or skip straight to ContentView()
struct RootView: View {
    @AppStorage("isProfileCreated") private var isProfileCreated = false
    @State private var isSplashScreenActive:Bool = true
    
    var body: some View {
        
        
        Group {
            if isSplashScreenActive {
                LandingPageView()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            withAnimation {
                                // Switch to main app after 3 seconds
                                isSplashScreenActive = false
                            }
                        }
                    }
            } else {
                if isProfileCreated {
                    ContentView()
                } else {
                    InspireView()

                }
            }
        }
    }
}
