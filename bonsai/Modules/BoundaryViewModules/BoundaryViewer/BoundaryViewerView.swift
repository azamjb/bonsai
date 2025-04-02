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
    
    @State private var showEditScren: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                if screenTime.limitsSet.isEmpty {
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
                                + Text(" to begin making your custom app limits and schedules. You're in control – create as many as you want to shape your ideal balance.")
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
                            
                            if !screenTime.limitsSet.isEmpty {
                                List {
                                    ForEach(screenTime.limitsSet) { limit in
                                        if !limit.invisibleLimit {
                                            LimitRow(limit: limit)
                                                .listRowSeparator(.hidden)
                                        }
                                    }
                                }
                                .listStyle(PlainListStyle())
                                .frame(minHeight: 175 * CGFloat(screenTime.limitsSet.count))
                            }
                        }
                    }
                    
                    Spacer()
                    
                    buttonContent
                        .padding(.bottom, 30)
                }
            }
            .navigationDestination(isPresented: $showEditScren) {
                BoundaryEditorView()
                    .onDisappear {
                        screenTime.setGroupDisplays()
                    }
            }
        }
    }
    
    private var buttonContent: some View {
        VStack {
            EditBoundariesButton(showEditScreen: $showEditScren)
        }
    }
}


private struct LimitRow: View {
    let limit: ScreenTimeActivityEvent
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(limit.givenName)
                    .font(.system(size: 24, weight: .medium))
                
                HStack {
                    ForEach(Array(Weekday.allCases), id: \.self) { day in
                        DayPin(day: day, limit: limit)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                HStack {
                    VStack {
                        Text(String(limit.hours))
                            .font(.system(size: 46))
                        
                        Text("H")
                            .font(.system(size: 16))
                    }
                    .padding(.trailing, 12)
                    
                    VStack {
                        Text(String(limit.minutes))
                            .font(.system(size: 46))
                        Text("MINS")
                            .font(.system(size: 16))
                    }
                }
            }
            
        }
        .padding(.horizontal, 35)
        
        HStack(spacing: -5) {
            ForEach(Array(limit.appTokens), id: \.self) { token in
                Label(token)
                    .labelStyle(.iconOnly)
                    .scaleEffect(1.7)
            }

            ForEach(Array(limit.webDomainTokens), id: \.self) { token in
                Label(token)
                    .labelStyle(.iconOnly)
                    .scaleEffect(1.7)
            }

            ForEach(Array(limit.categoryTokens), id: \.self) { token in
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
    let limit: ScreenTimeActivityEvent
    
    var body: some View {
        Text(day.label)
            .font(.system(size: 12))
            .frame(width: 15, height: 15)
            .background(Color.secondary)
            .cornerRadius(100)
            .opacity(limit.weekdays.contains(day) ? 0.8 : 0.2)
    }
}

private struct EditBoundariesButton: View {
    
    @Binding var showEditScreen: Bool
    @EnvironmentObject var screenTime: ScreenTimeService
    
    var body: some View {
        Button(action: {
            showEditScreen = true
        }) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 299, height: 51)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.primary, lineWidth: 1)
                )
                .overlay(
                    Text(screenTime.limitsSet.isEmpty ? "add new boundary" : "edit boundaries")
                        .foregroundColor(.primary)
                )
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
