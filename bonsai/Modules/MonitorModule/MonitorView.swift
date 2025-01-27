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

    @AppStorage(LocalStorageKeys.timeExtensionRequestCode) private var timeExtensionRequestCode: String?
    
    @StateObject private var viewModel = MonitorViewModel()
    @State private var timeExtensionService = TimeExtensionService()

    @State private var isPickerSheetPresented: Bool = false
    @State private var isScheduleSheetPresented: Bool = false
    @State private var isAppSelectionPresented: Bool = false
    @State private var isLimitSheetPresented: Bool = false

    @State private var currentBlockType: BlockTypes?
    @State private var currentAppToken: ApplicationToken?
    @State private var currentCategoryToken: ActivityCategoryToken?
    @State private var currentWebDomainToken: WebDomainToken?
    
    @State var activeLimits: [IdentifiableScreenTimeActivityEvent] = []

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
                            Text("Select Apps to Monitor")
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
                                Text("Limits")
                                    .font(.title2)
                                    .bold()
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                ForEach(activeLimits) { limit in
                                    LimitRow(limit: limit.screenTimeActivityEvent)
                                }
                            }
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
                            if viewModel.blockedCategories.isEmpty {
                                noLimitsView(type: .category)
                            } else {
                                limitsReachedView(blockType: .category)
                            }
                        }
                        
                        VStack(alignment: .leading) {
                            if viewModel.blockedWebDomains.isEmpty {
                                noLimitsView(type: .webDomain)
                            } else {
                                limitsReachedView(blockType: .webDomain)
                            }
                        }

                    }
                    .padding()
                }
                .sheet(isPresented: $isPickerSheetPresented) {
                    schedulePickerSheet()
                        .presentationDetents([.height(300)])
                }
                .sheet(isPresented: $isLimitSheetPresented) {
                    if let blockType = currentBlockType {
                        extensionSheet(
                            blockType: blockType,
                            appToken: currentAppToken,
                            categoryToken: currentCategoryToken,
                            webDomainToken: currentWebDomainToken
                        )
                        .presentationDetents([.height(500)])
                    }
                }
                .onAppear {
                    viewModel.updateBlocksDisplayed()
                    activeLimits = timeExtensionService.getActiveLimitsDisplay()
                }
            }
        }
    }

    private func noLimitsView(type: BlockTypes) -> some View {
        switch type {
            case .app:
                return Text("No apps blocked")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            case .category:
                return Text("No categories blocked")
                    .font(.title2)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            case .webDomain:
                return Text("No web domains blocked")
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
                        Text("Apps blocked")
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
                        Text("Categories blocked")
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
                        Text("Web domains blocked")
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
                .labelStyle(.iconOnly)
                .scaleEffect(1.7)
                .padding(.trailing)
            Label(token)
                .labelStyle(.titleOnly)

            Spacer()
            
            Button("Extend") {
                currentAppToken = token
                currentBlockType = .app
                isLimitSheetPresented = true
            }
        }
    }
    
    private func BlockedRow(token: ActivityCategoryToken) -> some View {
        HStack {
            Label(token)
                .labelStyle(.iconOnly)
                .scaleEffect(1.2)
                .padding(.trailing)
            Label(token)
                .labelStyle(.titleOnly)

            Spacer()
            
            Button("Extend") {
                currentCategoryToken = token
                currentBlockType = .category
                isLimitSheetPresented = true
            }
        }
    }
    
    private func BlockedRow(token: WebDomainToken) -> some View {
        HStack {
            Label(token)
                .labelStyle(.iconOnly)
                .scaleEffect(1.7)
                .padding(.trailing)
            Label(token)
                .labelStyle(.titleOnly)

            Spacer()
            
            Button("Extend") {
                currentWebDomainToken = token
                currentBlockType = .webDomain
                isLimitSheetPresented = true
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
    
    private func extensionSheet(blockType: BlockTypes, appToken: ApplicationToken?, categoryToken: ActivityCategoryToken?, webDomainToken: WebDomainToken?) -> some View {
        VStack(spacing: 20) {
            Text("Override Block")
                .font(.title)
                .bold()
                .padding(.top)
            
            switch blockType {
                case .app:
                    Label(appToken!)
                        .labelStyle(.titleAndIcon)
                        .scaleEffect(1.7)
                case .category:
                    Label(categoryToken!)
                        .labelStyle(.titleAndIcon)
                        .scaleEffect(1.2)
                case .webDomain:
                    Label(webDomainToken!)
                        .labelStyle(.titleAndIcon)
                        .scaleEffect(1.7)
            }

            Spacer()

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

                Button(action: {
                    Task {
                        timeExtensionService.extendLimitForToken(appToken: appToken!)
                        //await timeExtensionService.purchaseManualOverride()
                    }
                }) {
                    Text("Manual Override")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .contentShape(Rectangle())
                
                if (timeExtensionRequestCode != nil) {
                    VStack(spacing: 8) {
                        TextField("Enter 6-digit override PIN", text: $viewModel.enteredPin)
                            .keyboardType(.numberPad)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action:  {
                            UIApplication.shared.dismissKeyboard()
                            
                            if appToken != nil {
                                timeExtensionService.extendLimitForToken(appToken: appToken!) // TODO
                            } else if categoryToken != nil {
                                timeExtensionService.extendLimitForToken(categoryToken: categoryToken!) // TODO
                            } else if webDomainToken != nil {
                                timeExtensionService.extendLimitForToken(webDomainToken: webDomainToken!) // TODO
                            }
                        }) {
                            Text("Submit PIN")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .contentShape(Rectangle())
                        
                        if let error = timeExtensionService.pinError {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.body)
                        }
                    }
                }
            }
            .padding(.horizontal)

            Spacer()

            Button("Dismiss") {
                isLimitSheetPresented = false
            }
            .foregroundColor(.red)
            .padding(.bottom)
        }
        .padding()
    }
}
