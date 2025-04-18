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

    var body: some View {
        NavigationStack {
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
                                .padding(.top, 40)
                            
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
                    ZStack() {
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
                                .padding(.top, 40)
                                
                            
                            Text("\"It is not that we have a short time to live, but that we waste a lot of it.\" - Seneca")
                                .font(.system(size: 12))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                            
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
                                .frame(minHeight: 175 * CGFloat(screenTime.boundariesSet.count))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    buttonContent
                        .padding(.bottom, 30)
                }
            }
            .navigationDestination(isPresented: $showEditScreen) {
                BoundaryEditorView()
                    .onDisappear {
                        screenTime.setGroupDisplays()
                    }
            }
        }
        .alert(isPresented: $showCannotEditAlert) {
            Alert(
                title: Text("Out of Boundary edits"),
                message: Text("You've already used your 2 boundary extensions for the week.")
                               
            )
        }
    }
    
    private var buttonContent: some View {
        VStack {
            BonsaiButtonRegular(buttonText: screenTime.boundariesSet.isEmpty ? "add new boundary" : "edit boundaries") {
                if screenTime.getLeftoverWeeklySaves() > 0 {
                    showEditScreen = true
                } else {
                    //showCannotEditAlert = true
                    showEditScreen = true // Get rid of this an uncomment the above line to test the max boundary week thing
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
                    .scaleEffect(1.7)
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

struct BoundaryViewerView_Previews: PreviewProvider {
    static var previews: some View {
        let selectedTab = Binding.constant(2)
        
        return NavigationView {
            BoundaryViewerView(tabSelection: selectedTab)
                .environmentObject(ScreenTimeService())
        }
    }
}
