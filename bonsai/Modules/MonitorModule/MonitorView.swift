////
////  MonitorView.swift
////  bonsai
////
////  Created by Brayden O on 2025-01-01.
////
//import SwiftUI
//import FamilyControls
//import DeviceActivity
//import ManagedSettings
//import DigitEntryView
//
//struct MonitorView: View {
//    @Binding var tabSelection: Int
//    
//    @State private var overridePinInput: String = ""
//    @State private var tempHours: Int = 0
//    @State private var tempMinutes: Int = 15
//    @State private var tempSelectedWeekdays: Set<Weekday> = []
//
//    @ObservedObject private var viewModel = MonitorViewModel()
//    @ObservedObject private var screenTime = ScreenTimeService()
//    
//    // Sheet Bools
//    @State private var isPickerSheetPresented: Bool = false
//    @State private var isScheduleSheetPresented: Bool = false
//    @State private var isAppSelectionPresented: Bool = false
//    
//    @State private var showDeleteConfirmation: Bool = false
//    
//    @FocusState private var isTextFieldFocused: Bool
//
//    var body: some View {
//        NavigationView {
//            ScrollView(.vertical) {
//                ZStack(alignment: .top) {
//                    // Transparent background that catches taps
//                    Color.clear
//                        .contentShape(Rectangle())  // Make the entire area tappable
//                        .onTapGesture {
//                            UIApplication.shared.dismissKeyboard()
//                        }
//                        .ignoresSafeArea()
//                    
//                    VStack(spacing: 16) {
//                        Text("Monitoring")
//                            .font(.largeTitle)
//                            .padding(.top)
//                        
//                        // MARK: - Select Apps to Monitor
//                        Button {
//                            isPickerSheetPresented = true
//                        } label: {
//                            Text("Set a Limit")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                                .padding()
//                                .background(Color.blue)
//                                .cornerRadius(10)
//                        }
//                        
//                        // MARK: - Clear All Restrictions
//                        Button {
//                            Task {
//                                screenTime.clearAllRestrictions()
//                                // await screenTime.purchaseManualOverride()
//                            }
//                        }
//                        label: {
//                            Text("clear all blocks and set limits (testing)")
//                                .font(.headline)
//                                .foregroundColor(.white)
//                                .padding()
//                                .background(Color.red)
//                                .cornerRadius(10)
//                        }
//                        .padding(.top, 4)
//                        
//                        Spacer()
//                        
//                        // MARK: - Limits display
//                        VStack(alignment: .leading) {
//                            if screenTime.limitsSet.isEmpty {
//                                Text("No limits set")
//                                    .font(.title2)
//                                    .foregroundColor(.gray)
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                            } else {
//                                Text("Limits set")
//                                    .font(.title2)
//                                    .bold()
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                                
//                                ForEach(screenTime.limitsSet) { limit in
//                                    LimitRow(limit: limit)
//                                }
//                            }
//                        }
//                        
//                        Spacer()
//                        
//                        // MARK: - Blocks display
//                        VStack(alignment: .leading) {
//                            if screenTime.limitsReached.isEmpty {
//                                noBlocksView()
//                            } else {
//                                blocksView(blocks: screenTime.limitsReached)
//                            }
//                        }
//                    }
//                    .padding()
//                }
//                // MARK: - Limit selection sheet
//                .sheet(isPresented: $isPickerSheetPresented) {
//                    schedulePickerSheet()
//                        .presentationDetents([.height(400)])
//                        .onAppear() {
//                            if screenTime.selectedLimit != nil {
//                                screenTime.setFromSelectedLimit(selectedLimit: screenTime.selectedLimit!)
//                            }
//                        }
//                        .onDisappear() {
//                            screenTime.resetSelectedLimit()
//                        }
//                }
//                // MARK: - Blocked group sheet
//                .sheet(item: $screenTime.selectedBlock, onDismiss: {
//                    screenTime.selectedBlock = nil
//                    screenTime.pinError = nil
//                }) { block in
//                    extensionSheet(blockGroup: block)
//                        .presentationDetents([.height(500)])
//                }
//                // MARK: - Limit deletion confirmation
//                .alert("Delete Limit", isPresented: $showDeleteConfirmation) {
//                    Button("Cancel", role: .cancel) {
//                        screenTime.limitToDelete = nil
//                    }
//                    Button("Delete", role: .destructive) {
//                        if let limit = screenTime.limitToDelete {
//                            screenTime.deleteLimit(limit: limit)
//                        }
//                        screenTime.limitToDelete = nil
//                    }
//                } message: {
//                    Text("Are you sure you want to delete this limit?")
//                }
//            }
//        }
//    }
//    
//    // MARK: - Block Views
//    private func noBlocksView() -> some View {
//        return Text("Nothing blocked")
//            .font(.title2)
//            .foregroundColor(.gray)
//            .frame(maxWidth: .infinity, alignment: .leading)
//    }
//    
//    private func blocksView(blocks: [ScreenTimeActivityEvent]) -> some View {
//        return AnyView(
//            VStack(alignment: .leading) {
//                Text("Currently blocked")
//                    .font(.title2)
//                    .bold()
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                
//                ForEach(Array(blocks), id: \.self) { limit in
//                    blockedRow(block: limit)
//                }
//            }
//        )
//    }
//    
//    private func blockedRow(block: ScreenTimeActivityEvent) -> some View {
//        return HStack(spacing: 20) {
//            HStack(spacing: -5) {
//                if let appTokens = block.appTokens {
//                    ForEach(Array(appTokens), id: \.self) { token in
//                        Label(token)
//                            .labelStyle(.iconOnly)
//                            .scaleEffect(1.7)
//                    }
//                }
//                
//                if let webDomainTokens = block.webDomainTokens {
//                    ForEach(Array(webDomainTokens), id: \.self) { token in
//                        Label(token)
//                            .labelStyle(.iconOnly)
//                            .scaleEffect(1.7)
//                    }
//                }
//                
//                if let categoryTokens = block.categoryTokens {
//                    ForEach(Array(categoryTokens), id: \.self) { token in
//                        Label(token)
//                            .labelStyle(.iconOnly)
//                            .scaleEffect(1.2)
//                    }
//                }
//            }
//            
//            Spacer()
//            
//            Button("Extend") {
//                screenTime.selectedBlock = block
//            }
//        }
//    }
//    
//    private func extensionSheet(blockGroup: ScreenTimeActivityEvent) -> some View {
//        VStack(spacing: 20) {
//            Text("Override Block")
//                .font(.title)
//                .bold()
//            
//            // App Icons section
//            HStack(spacing: -5) {
//                if let appTokens = blockGroup.appTokens {
//                    ForEach(Array(appTokens), id: \.self) { token in
//                        Label(token)
//                            .labelStyle(.iconOnly)
//                            .scaleEffect(1.7)
//                    }
//                }
//                
//                if let webDomainTokens = blockGroup.webDomainTokens {
//                    ForEach(Array(webDomainTokens), id: \.self) { token in
//                        Label(token)
//                            .labelStyle(.iconOnly)
//                            .scaleEffect(1.7)
//                    }
//                }
//                
//                if let categoryTokens = blockGroup.categoryTokens {
//                    ForEach(Array(categoryTokens), id: \.self) { token in
//                        Label(token)
//                            .labelStyle(.iconOnly)
//                            .scaleEffect(1.2)
//                    }
//                }
//            }
//            
//            // Actions section
//            VStack(spacing: 16) {
//                Button(action: {
//                    Task {
//                        await screenTime.sendTimeRequest()
//                    }
//                }) {
//                    Text("Request Time")
//                        .font(.headline)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(8)
//                }
//                .contentShape(Rectangle())
//                
//                VStack(spacing: 8) {
//                    PINEntryField(pin: $overridePinInput, onComplete: {
//                        if overridePinInput.count == 6 {
//                            screenTime.validateExtensionCode(inputPin: overridePinInput, correctPin: screenTime.timeExtensionRequestCode ?? "", group: blockGroup)
//                        }
//                    })
//                    
//                    if let error = screenTime.pinError {
//                        Text(error)
//                            .foregroundColor(.red)
//                            .font(.body)
//                    }
//                }
//            }
//            .padding(.horizontal)
//        }
//        .padding()
//    }
//
//    // MARK: - Limit Views
//    private func LimitRow(limit: ScreenTimeActivityEvent) -> some View {
//        return HStack(spacing: 20) {
//            VStack {
//                Text(limit.givenName)
//                
//                HStack(spacing: -5) {
//                    if let appTokens = limit.appTokens {
//                        ForEach(Array(appTokens), id: \.self) { token in
//                            Label(token)
//                                .labelStyle(.iconOnly)
//                                .scaleEffect(1.7)
//                        }
//                    }
//                    
//                    if let webDomainTokens = limit.webDomainTokens {
//                        ForEach(Array(webDomainTokens), id: \.self) { token in
//                            Label(token)
//                                .labelStyle(.iconOnly)
//                                .scaleEffect(1.7)
//                        }
//                    }
//                    
//                    if let categoryTokens = limit.categoryTokens {
//                        ForEach(Array(categoryTokens), id: \.self) { token in
//                            Label(token)
//                                .labelStyle(.iconOnly)
//                                .scaleEffect(1.2)
//                        }
//                    }
//                }
//            }
//            
//            Spacer()
//            
//            VStack {
//                Text("\(limit.hours)hr \(limit.minutes) min").bold()
//                
//                HStack {
//                    ForEach(Array(Weekday.allCases), id: \.self) { weekday in
//                        if limit.weekdays.contains(weekday) {
//                            Text(weekday.label)
//                                .frame(width: 20, height: 20)
//                                .background(Color.black)
//                                .foregroundColor(.white)
//                                .cornerRadius(8)
//                                .overlay(
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .stroke(Color.white)
//                                )
//                        } else {
//                            Text(weekday.label)
//                        }
//                    }
//                }
//            }
//            
//            Menu {
//                Button(action: {
//                    screenTime.selectedLimit = limit
//                    isPickerSheetPresented = true
//                }) {
//                    Label("Edit", systemImage: "pencil")
//                }
//                
//                Button(action: {
//                    screenTime.limitToDelete = limit
//                    showDeleteConfirmation = true
//                }) {
//                    Label("Delete", systemImage: "trash")
//                        .foregroundColor(.red)
//                }
//            } label: {
//                Image(systemName: "ellipsis")
//                    .foregroundColor(.gray)
//                    .padding(8)
//                    .rotationEffect(Angle.degrees(90))
//            }
//        }
//    }
//    
//    private func schedulePickerSheet() -> some View {
//        return VStack(spacing: 20) {
//            VStack {
//                Text("Limit Group Name")
//                    .font(.headline)
//                    .frame(maxWidth: .infinity, alignment: .center)
//
//                TextField("Enter Limit Group Name", text: $screenTime.limitGroupName)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//            }
//            .onTapGesture {
//                isTextFieldFocused = false // Dismiss keyboard when tapping outside
//            }
//            
//            HStack {
//                if screenTime.selectedLimit != nil && screenTime.selectedLimit!.appTokens != nil {
//                    ForEach(Array(screenTime.selectedLimit!.appTokens!), id: \.self) { token in
//                        Label(token)
//                            .labelStyle(.iconOnly)
//                            .scaleEffect(1.7)
//                    }
//                }
//                
//                if screenTime.selectedLimit != nil && screenTime.selectedLimit!.categoryTokens != nil {
//                    ForEach(Array(screenTime.selectedLimit!.categoryTokens!), id: \.self) { token in
//                        Label(token)
//                            .labelStyle(.iconOnly)
//                            .scaleEffect(1.2)
//                    }
//                }
//
//                if screenTime.selectedLimit != nil && screenTime.selectedLimit!.webDomainTokens != nil {
//                    ForEach(Array(screenTime.selectedLimit!.webDomainTokens!), id: \.self) { token in
//                        Label(token)
//                            .labelStyle(.iconOnly)
//                            .scaleEffect(1.2)
//                    }
//                }
//            }
//            
//            Button {
//                isAppSelectionPresented = true
//            } label: {
//                Text("Select Apps")
//                    .font(.title3)
//            }
//            .frame(maxWidth: .infinity)
//            .buttonStyle(.bordered)
//            .familyActivityPicker(isPresented: $isAppSelectionPresented, selection: $screenTime.activitySelection)
//            
//            Button {
//                isScheduleSheetPresented = true
//            } label: {
//                Text("Set Schedule")
//                    .font(.title3)
//            }
//            .frame(maxWidth: .infinity)
//            .buttonStyle(.bordered)
//            
//            Button {
//                screenTime.startMonitoring(existingLimitId: screenTime.selectedLimit?.id)
//                isPickerSheetPresented = false
//            } label: {
//                Text("Start Monitoring")
//                    .font(.title3)
//            }
//            .frame(maxWidth: .infinity)
//            .buttonStyle(.borderedProminent)
//        }
//        .sheet(isPresented: $isScheduleSheetPresented) {
//            VStack(spacing: 20) {
//                HStack {
//                    Picker("", selection: $screenTime.limitHours){
//                        ForEach(0..<8, id: \.self) { i in
//                            Text("\(i) hours").tag(i)
//                        }
//                    }.pickerStyle(WheelPickerStyle())
//                    Picker("", selection: $screenTime.limitMinutes){
//                        ForEach(0..<60, id: \.self) { i in
//                            Text("\(i) min").tag(i)
//                        }
//                    }
//                    .pickerStyle(WheelPickerStyle())
//                }.padding(.horizontal)
//                
//                HStack {
//                    dayButton(day: .monday)
//                    dayButton(day: .tuesday)
//                    dayButton(day: .wednesday)
//                    dayButton(day: .thursday)
//                    dayButton(day: .friday)
//                    dayButton(day: .saturday)
//                    dayButton(day: .sunday)
//                }
//                
//                Button("Save") {
//                    isScheduleSheetPresented = false
//                }
//                .frame(maxWidth: .infinity)
//                .buttonStyle(.borderedProminent)
//            }
//            .presentationDetents([.height(400)])
//        }
//    }
//    
//    private func dayButton(day: Weekday) -> some View {
//        Button(action: {
//            screenTime.weekdaySelected(day: day)
//        }) {
//            Text(day.label)
//                .frame(width: 40, height: 40)
//                .background(screenTime.selectedWeekdays.contains(day) ? Color.blue : Color.clear)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//                .overlay(
//                    RoundedRectangle(cornerRadius: 8)
//                        .stroke(Color.blue, lineWidth: screenTime.selectedWeekdays.contains(day) ? 0 : 1)
//                )
//        }
//    }
//}
