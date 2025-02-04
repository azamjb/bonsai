//
//  MonitorView.swift
//  bonsai
//
//  Created by Brayden O on 2025-01-01.
//
import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings
import DigitEntryView

struct MonitorView: View {
    @Binding var tabSelection: Int
    
    @State private var overridePinInput: String = ""

    @ObservedObject private var viewModel = MonitorViewModel()
    @ObservedObject private var timeExtensionService = TimeExtensionService()
    
    // Bools
    @State private var isPickerSheetPresented: Bool = false
    @State private var isScheduleSheetPresented: Bool = false
    @State private var isAppSelectionPresented: Bool = false
    
    // Limit shit
    @State private var activeLimits: [ScreenTimeActivityEvent] = []
    @State private var activeBlocks: [ScreenTimeActivityEvent] = []
    @State private var selectedBlock: ScreenTimeActivityEvent? = nil
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                ZStack(alignment: .top) {
                    // 1. A transparent background that catches taps
                    Color.clear
                        .contentShape(Rectangle())  // Make the entire area tappable
                        .onTapGesture {
                            UIApplication.shared.dismissKeyboard()
                        }
                        .ignoresSafeArea()
                    
                    // 2. Your main content
                    VStack(spacing: 16) {
                        Text("Monitoring")
                            .font(.largeTitle)
                            .padding(.top)
                        
                        // MARK: - Select Apps to Monitor
                        Button {
                            isPickerSheetPresented = true
                        } label: {
                            Text("Set a Limit")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        
                        // MARK: - Clear All Restrictions
                        Button {
                            Task {
                                timeExtensionService.clearAllRestrictions()
                                // await timeExtensionService.purchaseManualOverride()
                            }
                        }
                        label: {
                            Text("clear all blocks and set limits (testing)")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .padding(.top, 4)
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            if activeLimits.isEmpty {
                                Text("No limits set")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            } else {
                                Text("Limits set")
                                    .font(.title2)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                ForEach(activeLimits) { limit in
                                    LimitRow(limit: limit)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            if activeBlocks.isEmpty {
                                noBlocksView()
                            } else {
                                blocksView(blocks: activeBlocks)
                            }
                        }
                    }
                    .padding()
                }
                .sheet(isPresented: $isPickerSheetPresented) {
                    schedulePickerSheet()
                        .presentationDetents([.height(300)])
                }
                .sheet(item: $selectedBlock, onDismiss: {
                    selectedBlock = nil
                    timeExtensionService.pinError = nil
                }) { block in
                    extensionSheet(blockGroup: block)
                        .presentationDetents([.height(500)])
                }
                .onAppear {
                    activeLimits = timeExtensionService.getGroupDisplay(displayType: .limit)
                    activeBlocks = timeExtensionService.getGroupDisplay(displayType: .block)
                }
            }
        }
    }
    
    private func noBlocksView() -> some View {
        return Text("Nothing blocked")
            .font(.title2)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func blocksView(blocks: [ScreenTimeActivityEvent]) -> some View {
        return AnyView(
            VStack(alignment: .leading) {
                Text("Currently blocked")
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(Array(blocks), id: \.self) { limit in
                    blockedRow(block: limit)
                }
            }
        )
    }
    
    private func blockedRow(block: ScreenTimeActivityEvent) -> some View {
        return HStack(spacing: 20) {
            HStack(spacing: -5) {
                if let appTokens = block.appTokens {
                    ForEach(Array(appTokens), id: \.self) { token in
                        Label(token)
                            .labelStyle(.iconOnly)
                            .scaleEffect(1.7)
                    }
                }
                
                if let webDomainTokens = block.webDomainTokens {
                    ForEach(Array(webDomainTokens), id: \.self) { token in
                        Label(token)
                            .labelStyle(.iconOnly)
                            .scaleEffect(1.7)
                    }
                }
                
                if let categoryTokens = block.categoryTokens {
                    ForEach(Array(categoryTokens), id: \.self) { token in
                        Label(token)
                            .labelStyle(.iconOnly)
                            .scaleEffect(1.2)
                    }
                }
            }
            Spacer()
            
            Button("Extend") {
                selectedBlock = block
            }
        }
    }
    
    private func LimitRow(limit: ScreenTimeActivityEvent) -> some View {
        return HStack(spacing: 20) {
            HStack(spacing: -5) {
                if let appTokens = limit.appTokens {
                    ForEach(Array(appTokens), id: \.self) { token in
                        Label(token)
                            .labelStyle(.iconOnly)
                            .scaleEffect(1.7)
                    }
                }
                
                if let webDomainTokens = limit.webDomainTokens {
                    ForEach(Array(webDomainTokens), id: \.self) { token in
                        Label(token)
                            .labelStyle(.iconOnly)
                            .scaleEffect(1.7)
                    }
                }
                
                if let categoryTokens = limit.categoryTokens {
                    ForEach(Array(categoryTokens), id: \.self) { token in
                        Label(token)
                            .labelStyle(.iconOnly)
                            .scaleEffect(1.2)
                    }
                }
            }
            
            Spacer()
            
            Text("\(limit.hours)hr \(limit.minutes) min").bold()
        }
    }
    
    private func schedulePickerSheet() -> some View {
        return VStack(spacing: 20) {
            Button {
                isAppSelectionPresented = true
            } label: {
                Text("Select Apps")
                    .font(.title3)
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.bordered)
            .familyActivityPicker(isPresented: $isAppSelectionPresented, selection: $timeExtensionService.activitySelection)
            
            Button {
                isScheduleSheetPresented = true
            } label: {
                Text("Select Schedule")
                    .font(.title3)
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.bordered)
            
            Button {
                timeExtensionService.startMonitoring()
                isPickerSheetPresented = false
            } label: {
                Text("Start Monitoring")
                    .font(.title3)
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(.borderedProminent)
        }
        .sheet(isPresented: $isScheduleSheetPresented) {
            VStack(spacing: 20) {
                HStack {
                    Picker("", selection: $timeExtensionService.limitHours){
                        ForEach(0..<8, id: \.self) { i in
                            Text("\(i) hours").tag(i)
                        }
                    }.pickerStyle(WheelPickerStyle())
                    Picker("", selection: $timeExtensionService.limitMinutes){
                        ForEach(0..<60, id: \.self) { i in
                            Text("\(i) min").tag(i)
                        }
                    }.pickerStyle(WheelPickerStyle())
                }.padding(.horizontal)
                Button("Save") {
                    isScheduleSheetPresented = false
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
            }
            .presentationDetents([.height(300)])
        }
    }
    
    private func extensionSheet(blockGroup: ScreenTimeActivityEvent) -> some View {
        VStack(spacing: 20) {
            Text("Override Block")
                .font(.title)
                .bold()
            
            // App Icons section
            HStack(spacing: -5) {
                if let appTokens = blockGroup.appTokens {
                    ForEach(Array(appTokens), id: \.self) { token in
                        Label(token)
                            .labelStyle(.iconOnly)
                            .scaleEffect(1.7)
                    }
                }
                
                if let webDomainTokens = blockGroup.webDomainTokens {
                    ForEach(Array(webDomainTokens), id: \.self) { token in
                        Label(token)
                            .labelStyle(.iconOnly)
                            .scaleEffect(1.7)
                    }
                }
                
                if let categoryTokens = blockGroup.categoryTokens {
                    ForEach(Array(categoryTokens), id: \.self) { token in
                        Label(token)
                            .labelStyle(.iconOnly)
                            .scaleEffect(1.2)
                    }
                }
            }
            
            // Actions section
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        await timeExtensionService.sendTimeRequest()
                    }
                }) {
                    Text("Request Time")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .contentShape(Rectangle())
                
                VStack(spacing: 8) {
                    PINEntryField(pin: $overridePinInput, onComplete: {
                        if overridePinInput.count == 6 {
                            timeExtensionService.validateExtensionCode(inputPin: overridePinInput, correctPin: timeExtensionService.timeExtensionRequestCode ?? "", group: blockGroup)
                        }
                    })
                    
                    if let error = timeExtensionService.pinError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.body)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding()
    }
}
