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
    
    @AppStorage(LocalStorageKeys.timeExtensionRequestCode) private var timeExtensionRequestCode: String?
    @StateObject private var viewModel = MonitorViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
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
                        viewModel.clearAllRestrictions()
                    } label: {
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
                }
                .padding()
            }
        }
    }
}
