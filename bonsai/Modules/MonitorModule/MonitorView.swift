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

struct MonitorView: View {
    @Binding var tabSelection: Int

    @AppStorage(LocalStorageKeys.timeExtensionRequestCode) private var timeExtensionRequestCode: String?
    @StateObject private var viewModel = MonitorViewModel()
    @State private var isSheetPresented: Bool = false

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
                        
                        // MARK: - Time Limit Input
                        VStack {
                            Text("Enter Time Limit (minutes)")
                                .font(.headline)
                            
                            TextField("Time limit (e.g. 15)", text: $viewModel.timeLimitMinutesString)
                                .keyboardType(.numberPad)
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 200)
                        }
                        
                        // MARK: - Select Apps to Monitor
                        Button {
                            viewModel.pickerIsPresented = true
                        } label: {
                            Text("Select Apps to Monitor")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.top, 4)
                        .familyActivityPicker(isPresented: $viewModel.pickerIsPresented, selection: $viewModel.activitySelection)
                        .onChange(of: viewModel.activitySelection) { selection in
                            viewModel.saveSelection(for: selection)
                        }
                        
                        // MARK: - Start Monitoring
                        Button {
                            viewModel.startMonitoring()
                        } label: {
                            Text(viewModel.monitoringStarted ? "Monitoring Started" : "Start Monitoring")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(viewModel.monitoringStarted ? Color.gray : Color.green)
                                .cornerRadius(10)
                        }
                        .disabled(viewModel.monitoringStarted)
                        .padding(.top, 4)
                        
                        // MARK: - Clear All Restrictions
                        Button {
                            Task {
                                // viewModel.clearAllRestrictions() - NO IN APP PURCHASE (testing)
                                await viewModel.purchaseManualOverride()
                            }
                        }
                     label: {
                        Text("Manual Override")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(10)
                    }
                    .padding(.top, 4)
                    
                    if (timeExtensionRequestCode != nil) {
                        
                        VStack(spacing: 8) {
                            SecureField("Enter 6-digit PIN", text: $viewModel.enteredPin)
                                .keyboardType(.numberPad)
                                .padding()
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 200)
                            
                            Button {
                                UIApplication.shared.dismissKeyboard() // Dismiss keyboard
                                viewModel.validateAndExtendTime()
                            } label: {
                                Text("Submit PIN")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        
                    }
                    
                        // Error message for wrong PIN
                        if let error = viewModel.pinError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            if viewModel.blockedApps.isEmpty {
                                noLimitsView(type: .app)
                            } else {
                                limitsReachedView(blockType: .app)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            if viewModel.blockedApps.isEmpty {
                                noLimitsView(type: .category)
                            } else {
                                limitsReachedView(blockType: .category)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            if viewModel.blockedApps.isEmpty {
                                noLimitsView(type: .webDomain)
                            } else {
                                limitsReachedView(blockType: .webDomain)
                            }
                        }

                    }
                    .padding()
                }
                .onAppear {
                    viewModel.updateBlocksDisplayed()
                }
            }
        }
    }
    
    enum BlockTypes: String {
        case app
        case category
        case webDomain
    }
    
    private func noLimitsView(type: BlockTypes) -> some View {
        switch type {
            case .app:
                return Text("No app limits reached")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            case .category:
                return Text("No category limits reached")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            case .webDomain:
                return Text("No web domain reached")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func limitsReachedView(blockType: BlockTypes) -> some View {
        switch blockType {
            case .app:
                return AnyView(
                    VStack(alignment: .leading) {
                        Text("App limits reached")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(Array(viewModel.blockedApps), id: \.self) { token in
                            BlockedRow(token: token)
                        }
                    }
                )
                
            case .category:
                return AnyView(
                    VStack(alignment: .leading) {
                        Text("Category limits reached")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(Array(viewModel.blockedCategories), id: \.self) { token in
                            BlockedRow(token: token)
                        }
                    }
                )
                
            case .webDomain:
                return AnyView(
                    VStack(alignment: .leading) {
                        Text("Web domain limits reached")
                            .font(.title2)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        ForEach(Array(viewModel.blockedWebDomains), id: \.self) { token in
                            BlockedRow(token: token)
                        }
                    }
                )
        }
    }

    private func BlockedRow(token: ApplicationToken) -> some View {
        HStack {
            Label(token)
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button("Extend") {
                isSheetPresented = true
            }
            .sheet(isPresented: $isSheetPresented) {
                VStack {
                    Text("Popup Content")
                    Button("Dismiss") {
                        isSheetPresented = false
                    }
                }
                .padding()
            }
        }
    }
    
    private func BlockedRow(token: ActivityCategoryToken) -> some View {
        HStack {
            Label(token)
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button("Extend") {
                isSheetPresented = true
            }
            .sheet(isPresented: $isSheetPresented) {
                VStack {
                    Text("Popup Content")
                    Button("Dismiss") {
                        isSheetPresented = false
                    }
                }
                .padding()
            }
        }
    }
    
    private func BlockedRow(token: WebDomainToken) -> some View {
        HStack {
            Label(token)
                .labelStyle(.titleAndIcon)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Button("Extend") {
                isSheetPresented = true
            }
            .sheet(isPresented: $isSheetPresented) {
                VStack {
                    Text("Popup Content")
                    Button("Dismiss") {
                        isSheetPresented = false
                    }
                }
                .padding()
            }
        }
    }
}
