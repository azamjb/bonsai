//
//  BoundaryEditorView.swift
//  bonsai
//
//  Created by Brayden O on 2025-03-09.
//

import SwiftUICore
import SwiftUI

struct BoundaryEditorView: View {
    @ObservedObject private var viewModel = BoundaryEditorViewModel()
    @EnvironmentObject var screenTime: ScreenTimeService
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedLimit: ScreenTimeActivityEvent? = nil
    @State private var showViewScreen: Bool = false
    @State private var modifiedLimits: [ScreenTimeActivityEvent] = []
    @State private var limitIdsToDelete: [UUID] = []

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack {
                    headerContent
                    limitsContent
                }
                .frame(maxHeight: .infinity)
            }
            buttonContent
        }
        .navigationDestination(isPresented: $showViewScreen) {
            BoundaryDetailsView(
                selectedLimit: selectedLimit != nil ? $selectedLimit : .constant(nil),
                allLimits: $screenTime.limitsSet,
                modifiedLimits: $modifiedLimits,
                isPresented: $showViewScreen
            )
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left") // Custom back arrow icon
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                }
            }
        }
    }
    
    
    // MARK: - Extracted Views
    
    private var headerContent: some View {
        ZStack(alignment: .top) {
            // Transparent background that catches taps
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("BOUNDARY EDITOR")
                    .bold()
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                    .frame(width: 331, alignment: .top)
                
                Text("\"It is not that we have a short time to live, but that we waste a lot of it.\" - Seneca")
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
                    .frame(width: 245, height: 43, alignment: .top)
            }
            .padding(.top, 8)
        }
    }
    
    private var limitsContent: some View {
        Group {
            if !screenTime.limitsSet.isEmpty {
                limitsListView
            }
        }
    }
    
    private var limitsListView: some View {
        let uniqueLimits = screenTime.limitsSet.filter { limit in
            !modifiedLimits.contains(where: { $0.id == limit.id })
        }
        let count = uniqueLimits.count + modifiedLimits.count
        
        return List {
            ForEach(uniqueLimits) { limit in
                if (!limit.invisibleLimit) { // only display it if its not an invisible limit
                    limitRowView(for: limit)
                }
            }
            
            ForEach(modifiedLimits) { limit in
                if (!limit.invisibleLimit) { // only display it if its not an invisible limit
                    limitRowView(for: limit)
                }
            }
        }
        .listStyle(PlainListStyle())
        .frame(minHeight: 175 * CGFloat(count))
    }
    
    private func limitRowView(for limit: ScreenTimeActivityEvent) -> some View {
        LimitRow(limit: limit)
            .listRowSeparator(.hidden)
            .swipeActions(edge: .trailing) {
                DeleteLimitButton(limitIdsToDelete: $limitIdsToDelete, limitId: limit.id)
            }
            .tint(.red)
            .swipeActions(edge: .leading) {
                Button {
                    self.selectedLimit = limit
                    self.showViewScreen = true
                } label: {
                    Label("", systemImage: "pencil")
                }
            }
            .tint(.blue)
    }
    
    private var buttonContent: some View {
        VStack {
            AddBoundaryButton(selectedLimit: $selectedLimit, showViewScreen: $showViewScreen)
            SaveButton {
                modifiedLimits.forEach { limit in
                    screenTime.startMonitoring(limit: limit)
                }
                
                limitIdsToDelete.forEach { id in
                    screenTime.deleteLimit(limitId: id)
                }
                
                presentationMode.wrappedValue.dismiss()
            }
            
            // FOR TESTING
            Button {
                Task {
                    screenTime.clearAllRestrictions()
                }
            }
            label: {
                Text("clear all blocks and set limits (testing)")
            }
        }
        .padding(.bottom, 20)
    }
}

// MARK: - Supporting Views

private struct DeleteLimitButton: View {
    @Binding var limitIdsToDelete: [UUID]
    var limitId: UUID
    
    var body: some View {
        Button(role: .destructive) {
            limitIdsToDelete.append(limitId)
        } label: {
            Label("", systemImage: "trash")
        }
    }
}

private struct AddBoundaryButton: View {
    @Binding var selectedLimit: ScreenTimeActivityEvent?
    @Binding var showViewScreen: Bool
    
    var body: some View {
        Button(action: {
            selectedLimit = nil
            showViewScreen = true
        }) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 299, height: 51)
                .background(Color.white)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.black, lineWidth: 1)
                )
                .overlay(
                    Text("add new boundary")
                        .foregroundColor(.black)
                )
        }
    }
}

private struct SaveButton: View {
    var onSave: () -> Void
    
    init(onSave: @escaping () -> Void) {
        self.onSave = onSave
    }
    
    var body: some View {
        Button(action: {
            onSave()
        }) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 299, height: 51)
                .background(Color.white)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.black, lineWidth: 1)
                )
                .overlay(
                    Text("save")
                        .foregroundColor(.black)
                )
        }
    }
}

private struct DayPin: View {
    let day: Weekday
    let limit: ScreenTimeActivityEvent
    
    var body: some View {
        Text(day.label)
            .font(.system(size: 14))
            .frame(width: 19, height: 19)
            .background(Color(red: 0.85, green: 0.85, blue: 0.85))
            .cornerRadius(100)
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .stroke(Color(red: 0.85, green: 0.85, blue: 0.85))
            )
            .opacity(limit.weekdays.contains(day) ? 1 : 0.4)
    }
}

private struct LimitRow: View {
    let limit: ScreenTimeActivityEvent
    
    var body: some View {
        VStack(spacing: 4) {
            headerView
            
            limitDetailsView
            
            scheduleHeaderView
            
            dayPinsView
            
            Divider()
                .frame(height: 1)
                .padding(.horizontal, 35)
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("LABEL")
                .font(.system(size: 12))
                .foregroundColor(Color(red: 0.54, green: 0.54, blue: 0.54))
                .bold()
            
            Spacer()
            
            Text("DAILY LIMIT")
                .font(.system(size: 12))
                .foregroundColor(Color(red: 0.54, green: 0.54, blue: 0.54))
                .bold()
        }
        .padding(.horizontal, 35)
    }
    
    private var limitDetailsView: some View {
        HStack {
            if (limit.givenName.isEmpty) {
                Text("Unnamed Limit")
                    .font(.system(size: 18))
            } else {
                Text(limit.givenName)
                    .font(.system(size: 18))
            }
            
            Spacer()
            
            timeView
        }
        .padding(.horizontal, 35)
        .padding(.bottom, 15)
    }
    
    private var timeView: some View {
        HStack {
            Text(String(limit.hours))
                .font(.system(size: 18))
                .fontWeight(.semibold)
            Text("hrs")
                .font(.system(size: 12))
            
            Text(String(limit.minutes))
                .font(.system(size: 18))
                .fontWeight(.semibold)
            Text("mins")
                .font(.system(size: 12))
        }
    }
    
    private var scheduleHeaderView: some View {
        HStack {
            Spacer()
            
            Text("SCHEDULE")
                .font(.system(size: 12))
                .foregroundColor(Color(red: 0.54, green: 0.54, blue: 0.54))
                .bold()
        }
        .padding(.horizontal, 35)
    }
    
    private var dayPinsView: some View {
        HStack {
            Spacer()
            
            DayPin(day: .monday, limit: limit)
            DayPin(day: .tuesday, limit: limit)
            DayPin(day: .wednesday, limit: limit)
            DayPin(day: .thursday, limit: limit)
            DayPin(day: .friday, limit: limit)
            DayPin(day: .saturday, limit: limit)
            DayPin(day: .sunday, limit: limit)
        }
        .padding(.horizontal, 35)
        .padding(.bottom, 20)
    }
}
