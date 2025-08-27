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
    
    @State private var selectedBoundary: Boundary? = nil
    @State private var showViewScreen: Bool = false
    @State private var modifiedBoundaries: [Boundary] = []
    @State private var boundaryIdsToDelete: [UUID] = []
    
    @State private var showingCancelConfirmation: Bool = false
    @State private var showingDeleteConfirmation: Bool = false
    @State private var showingEditConfirmation: Bool = false
    @State private var boundaryService = BoundaryService(storage: BoundaryStorageService(database: LocalDatabase.shared.databaseWriter))

    var body: some View {
        VStack(spacing: 0) {
            headerContent
                .padding(.bottom, 10)
            
            boundariesContent
                .layoutPriority(1)
            
            buttonContent
                .padding(.bottom, 30)
        }
        
        .edgesIgnoringSafeArea(.bottom)
        .navigationDestination(isPresented: $showViewScreen) {
            BoundaryDetailsView(
                selectedBoundary: selectedBoundary != nil ? $selectedBoundary : .constant(nil),
                allBoundaries: $screenTime.boundariesSet,
                modifiedBoundaries: $modifiedBoundaries,
                isPresented: $showViewScreen,
                boundariesBeingDeleted: Binding.constant(boundaryIdsToDelete.map({ boundaryService.getBoundaryById(boundaryId: $0) }))
            )
        }
        .customBackToolbar()
        
        .alert("Unsaved changes will be lost", isPresented: $showingCancelConfirmation) {
            Button("discard changes", role: .cancel) {
                presentationMode.wrappedValue.dismiss()
            }.backgroundStyle(Color(UIColor.systemRed))
            
            Button("keep editing") {
                showingCancelConfirmation = false
            }
        } message: {
            Text("Are you sure you want to exit?")
        }
        .alert("Are you sure you want to save?", isPresented: $showingEditConfirmation) {
            Button("save", role: .cancel) {
                if !boundaryIdsToDelete.isEmpty {
                    showingEditConfirmation = false
                    showingDeleteConfirmation = true
                } else {
                    modifiedBoundaries.forEach { boundary in
                        screenTime.startMonitoring(boundary: boundary)
                    }
                    
                    presentationMode.wrappedValue.dismiss()
                }
            }.backgroundStyle(Color(UIColor.systemRed))
            
            Button("keep editing") {
                showingEditConfirmation = false
            }
        } message: {
            Text("Once saved, you'll be able to change your balance sheet 2x a week. ")
        }
        .alert("Are you sure you want to delete a boundary?", isPresented: $showingDeleteConfirmation) {
            Button("delete", role: .cancel) {
                boundaryIdsToDelete.forEach { id in
                    print(id)
                    screenTime.deleteBoundary(boundaryId: id)
                }
                
                modifiedBoundaries.filter({ boundary in !boundaryIdsToDelete.contains(where: { $0 == boundary.id }) }).forEach { boundary in
                    screenTime.startMonitoring(boundary: boundary)
                }
                
                presentationMode.wrappedValue.dismiss()
            }.backgroundStyle(Color(UIColor.systemRed))
            
            Button("cancel") {
                showingDeleteConfirmation = false
            }
        } message: {
            Text("Once deleted, a boundary cannot be recovered.")
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
            
            VStack(spacing: 16) {
                Text("BOUNDARY EDITOR")
                    .bold()
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
        }
    }
    
    private var boundariesContent: some View {
        Group {
            if !screenTime.boundariesSet.isEmpty {
                boundariesListView
            } else {
                Spacer()
            }
        }
    }
    
    private var boundariesListView: some View {
        let uniqueBoundaries = screenTime.boundariesSet.filter { boundary in
            !modifiedBoundaries.contains(where: { $0.id == boundary.id }) && !boundaryIdsToDelete.contains(boundary.id)
        }
        
        let visibleModifiedBoundaries = modifiedBoundaries.filter { boundary in
            !boundaryIdsToDelete.contains(boundary.id)
        }
        
        return List {
            ForEach(uniqueBoundaries) { boundary in
                boundaryRowView(for: boundary)
            }
            
            ForEach(visibleModifiedBoundaries) { boundary in
                boundaryRowView(for: boundary)
            }
        }
        .listStyle(PlainListStyle())
    }
     
     private func boundaryRowView(for boundary: Boundary) -> some View {
         BoundaryRow(boundary: boundary)
             .listRowSeparator(.hidden)
             .swipeActions(edge: .trailing) {
                 DeleteBoundaryButton(boundaryIdsToDelete: $boundaryIdsToDelete, boundaryId: boundary.id)
             }
             .tint(.red)
             .swipeActions(edge: .leading) {
                 Button {
                     self.selectedBoundary = boundary
                     self.showViewScreen = true
                 } label: {
                     Label("", systemImage: "square.and.pencil")
                 }
             }
             .tint(.blue)
     }
    
    private var buttonContent: some View {
        VStack(spacing: 15) {
            BonsaiButtonRegular(buttonText: "add new boundary") {
                Task {
                    // Add a small delay to allow state to stabilize
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                    DispatchQueue.main.async {
                selectedBoundary = nil
                showViewScreen = true
                    }
                }
            }
            
            BonsaiButtonRegular(buttonText: "save") {
                showingEditConfirmation = true
            }
        }
    }
}

// MARK: - Supporting Views
private struct DeleteBoundaryButton: View {
    @Binding var boundaryIdsToDelete: [UUID]
    var boundaryId: UUID
    
    var body: some View {
        Button(role: .destructive) {
            boundaryIdsToDelete.append(boundaryId)
        } label: {
            Label("", systemImage: "trash")
        }
    }
}

private struct DayPin: View {
    let day: Weekday
    let boundary: Boundary
    
    var body: some View {
        Text(day.label)
            .font(.system(size: 14))
            .frame(width: 19, height: 19)
            .background(Color.secondary)
            .cornerRadius(100)
            .opacity(boundary.weekdays.contains(day) ? 0.8 : 0.2)
    }
}

private struct BoundaryRow: View {
    let boundary: Boundary
    
    var body: some View {
        VStack(spacing: 4) {
            headerView
            
            boundaryDetailsView
            
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
    
    private var boundaryDetailsView: some View {
        HStack {
            if (boundary.givenName.isEmpty) {
                Text("Unnamed Boundary")
                    .font(.system(size: 18))
            } else {
                Text(boundary.givenName)
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
            Text(String(boundary.hours))
                .font(.system(size: 18))
                .fontWeight(.semibold)
            Text("hrs")
                .font(.system(size: 12))
            
            Text(String(boundary.minutes))
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
                .padding(.bottom, 5)
        }
        .padding(.horizontal, 35)
    }
    
    private var dayPinsView: some View {
        HStack {
            Spacer()
            
            DayPin(day: .sunday, boundary: boundary)
            DayPin(day: .monday, boundary: boundary)
            DayPin(day: .tuesday, boundary: boundary)
            DayPin(day: .wednesday, boundary: boundary)
            DayPin(day: .thursday, boundary: boundary)
            DayPin(day: .friday, boundary: boundary)
            DayPin(day: .saturday, boundary: boundary)
        }
        .padding(.horizontal, 35)
        .padding(.bottom, 20)
    }
}

struct BoundaryEditorView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BoundaryEditorView()
                .environmentObject(ScreenTimeService())
        }
    }
}
