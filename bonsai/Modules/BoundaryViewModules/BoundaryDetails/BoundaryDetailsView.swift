
//  BoundaryDetailsView.swift
//  bonsai
//
//  Created by Brayden O on 2025-03-09.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct BoundaryDetailsView: View {
    @Binding var selectedLimit: ScreenTimeActivityEvent?
    @Binding var allLimits: [ScreenTimeActivityEvent]
    @Binding var modifiedLimits: [ScreenTimeActivityEvent]
    @Binding var isPresented: Bool
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var limitToUse: ScreenTimeActivityEvent
    @State private var isNewLimit: Bool
    @State private var deepCopiedExistingLimit: ScreenTimeActivityEvent?
    @State private var isShowingFamilyActivityPicker: Bool = false
    @State private var activitySelection: FamilyActivitySelection = FamilyActivitySelection()

    init(selectedLimit: Binding<ScreenTimeActivityEvent?>,
         allLimits: Binding<[ScreenTimeActivityEvent]>,
         modifiedLimits: Binding<[ScreenTimeActivityEvent]>,
         isPresented: Binding<Bool>
    ) {
        print(selectedLimit)
        self._selectedLimit = selectedLimit
        self._allLimits = allLimits
        self._modifiedLimits = modifiedLimits
        self._isPresented = isPresented
        
        let defaultLimit = ScreenTimeActivityEvent(
            id: UUID(),
            givenName: "Unnamed Limit",
            appTokens: [],
            categoryTokens: [],
            webDomainTokens: [],
            hours: 0,
            minutes: 15,
            weekdays: [],
            invisibleLimit: false)
        
        if let currentLimit = selectedLimit.wrappedValue {
            self._limitToUse = State(initialValue: currentLimit)
            deepCopiedExistingLimit = DeepCopier.Copy(currentLimit)

            isNewLimit = false
            
            var tempSelection = FamilyActivitySelection()
            tempSelection.applicationTokens = currentLimit.appTokens
            tempSelection.categoryTokens = currentLimit.categoryTokens
            tempSelection.webDomainTokens = currentLimit.webDomainTokens
            self._activitySelection = State(initialValue: tempSelection)
        } else {
            self._limitToUse = State(initialValue: defaultLimit)
            
            isNewLimit = true
        }
    }
    
    var body: some View {
        VStack {
            ScrollView(.vertical) {
                ZStack(alignment: .top) {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            UIApplication.shared.dismissKeyboard()
                        }
                        .ignoresSafeArea()
                    
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Text("Boundary Details")
                            .font(.system(size: 30))
                            .multilineTextAlignment(.center)
                            .frame(width: 331, alignment: .top)
                            .padding(.top, 20)
                        
                        List {
                            Section {
                                NavigationLink(destination: BoundaryLabelEditor(limit: $limitToUse)) {
                                    HStack {
                                        Text("BOUNDARY LABEL")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text(limitToUse.givenName)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 5)
                                    .padding(.vertical)
                                }
                            }
                            
                            Section {
                                NavigationLink(destination: DaysActiveEditor(limit: $limitToUse)) {
                                    HStack {
                                        Text("DAYS ACTIVE")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        DaysView(days: limitToUse.weekdays)
                                    }
                                    .padding(.horizontal, 5)
                                    .padding(.vertical)
                                }
                            }
                            
                            Section {
                                NavigationLink(destination: TimeLimitEditor(limit: $limitToUse)) {
                                    HStack {
                                        Text("DAILY LIMIT")
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Text("\(limitToUse.hours) hrs, \(limitToUse.minutes) mins")
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.horizontal, 5)
                                    .padding(.vertical)
                                }
                            }
                             
                            Section {
                                Button(action: {
                                    isShowingFamilyActivityPicker = true
                                }) {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("SELECTED APPS")
                                            .foregroundColor(.primary)
                                        
                                        if activitySelection.applicationTokens.isEmpty
                                            && activitySelection.categoryTokens.isEmpty
                                            && activitySelection.webDomainTokens.isEmpty
                                        {
                                            Text("No apps selected")
                                                .foregroundColor(.gray)
                                                .padding(.vertical, 5)
                                        } else {
                                            SelectedAppDisplay(
                                                appTokens: $activitySelection.applicationTokens,
                                                categoryTokens: $activitySelection.categoryTokens,
                                                webDomainTokens: $activitySelection.webDomainTokens
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 5)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                        .frame(height: 380)
                        
                        Spacer()

                        SaveButton() {
                            limitToUse.appTokens = activitySelection.applicationTokens
                            limitToUse.categoryTokens = activitySelection.categoryTokens
                            limitToUse.webDomainTokens = activitySelection.webDomainTokens
                            
                            if !isNewLimit {
                                if let index = allLimits.firstIndex(where: { $0.id == limitToUse.id }) {
                                    allLimits[index] = limitToUse
                                }
                            } else {
                                if allLimits.contains(where: { $0.id == limitToUse.id }) {
                                    limitToUse.id = UUID() // Create a new UUID if there's a conflict
                                }
                                allLimits.append(limitToUse)
                            }
                            
                            if !modifiedLimits.contains(where: { $0.id == limitToUse.id }) {
                                modifiedLimits.append(limitToUse)
                            } else {
                                if let index = modifiedLimits.firstIndex(where: { $0.id == limitToUse.id }) {
                                    modifiedLimits[index] = limitToUse
                                }
                            }
                            
                            isPresented = false
                        }
                        CancelButton() {
                            if !isNewLimit {
                                limitToUse = deepCopiedExistingLimit!
                            }
                            
                            isPresented = false
                        }
                    }
                    .padding()
                }
            }
            .familyActivityPicker(isPresented: $isShowingFamilyActivityPicker, selection: $activitySelection)
            .navigationBarBackButtonHidden(true)
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

private struct CancelButton: View {
    var onCancel: () -> Void
    
    init(onCancel: @escaping () -> Void) {
        self.onCancel = onCancel
    }
    
    var body: some View {
        Button(action: {
            onCancel()
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
                    Text("cancel")
                        .foregroundColor(.black)
                )
        }
    }
}

private struct DaysView: View {
    let days: Set<Weekday>
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(Weekday.allCases, id: \.self) { day in
                ZStack {
                    Circle()
                        .fill(days.contains(day) ? Color.gray : Color.gray.opacity(0.3))
                        .frame(width: 18, height: 24)
                    
                    Text(day.label)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(days.contains(day) ? .white : .gray)
                }
            }
        }
    }
}

// MARK: - Boundary Label Editor
private struct BoundaryLabelEditor: View {
    @Binding var limit: ScreenTimeActivityEvent
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            headerView()
            inputFieldView()
            
            Spacer()
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
    }
    
    private func headerView() -> some View {
        VStack(spacing: 10) {
            Text("label")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("return")
                }
                .foregroundColor(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 20)
    }
    
    private func inputFieldView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("BOUNDARY NAME")
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 15)
                .background(Color(UIColor.systemGray5))
            
            TextField("", text: $limit.givenName)
                .padding(.horizontal, 20)
                .padding(.vertical, 15)
                .foregroundStyle(Color.secondary)
                .background(Color(UIColor.systemGray5))
        }
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }
}

// MARK: - Days Active Editor
private struct DaysActiveEditor: View {
    @Binding var limit: ScreenTimeActivityEvent
    @Environment(\.presentationMode) var presentationMode
    var onSave: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            headerView()
            daysSelectorView()
            
            Spacer()
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
    }
    
    private func headerView() -> some View {
        VStack(spacing: 10) {
            Text("schedule")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("return")
                }
                .foregroundColor(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 20)
    }
    
    private func daysSelectorView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("DAYS ACTIVE")
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 15)
                .background(Color(UIColor.systemGray5))
            
            daysList()
        }
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }
    
    private func daysList() -> some View {
        VStack(spacing: 0) {
            ForEach(Weekday.allCases, id: \.self) { day in
                dayRow(day)
                
                if day != Weekday.allCases.last {
                    Divider()
                        .padding(.leading, 20)
                }
            }
        }
    }
    
    private func dayRow(_ day: Weekday) -> some View {
        Button(action: {
            toggleWeekday(day)
        }) {
            HStack {
                Circle()
                    .stroke(Color.gray, lineWidth: 1)
                    .background(
                        Circle()
                            .fill(limit.weekdays.contains(day) ? Color.secondary : Color.clear)
                    )
                    .frame(width: 24, height: 24)
                
                Text(day.label)
                    .font(.body)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func toggleWeekday(_ day: Weekday) {
        if limit.weekdays.contains(day) {
            limit.weekdays.remove(day)
        } else {
            limit.weekdays.insert(day)
        }
        
        if let onSave = onSave {
            onSave()
        }
    }
}

// MARK: - Time Limit Editor
private struct TimeLimitEditor: View {
    @Binding var limit: ScreenTimeActivityEvent
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 0) {
            headerView()
            limitSelectorView()
            
            Spacer()
        }
        .edgesIgnoringSafeArea(.bottom)
        .navigationBarBackButtonHidden(true)
    }
    
    private func headerView() -> some View {
        VStack(spacing: 10) {
            Text("time")
                .font(.title)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("return")
                }
                .foregroundColor(Color.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 20)
    }
    
    private func limitSelectorView() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("DAILY LIMIT")
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 15)
                .background(Color(UIColor.systemGray5))
            
            HStack {
                Text("HOURS")
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Text("MINUTES")
                    .fontWeight(.medium)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            HStack {
                Picker("", selection: $limit.hours){
                    ForEach(0..<8, id: \.self) { i in
                        Text("\(i) hours").tag(i)
                    }
                }.pickerStyle(WheelPickerStyle())
                
                Picker("", selection: $limit.minutes){
                    ForEach(0..<60, id: \.self) { i in
                        Text("\(i) min").tag(i)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }.padding(.horizontal)        }
        .background(Color(UIColor.systemGray5))
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }
}

// MARK: - Selected app display
private struct SelectedAppDisplay: View {
    @Binding var appTokens: Set<ApplicationToken>
    @Binding var categoryTokens: Set<ActivityCategoryToken>
    @Binding var webDomainTokens: Set<WebDomainToken>

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -5) {
                ForEach(Array(appTokens), id: \.self) { token in
                    Label(token)
                        .labelStyle(.iconOnly)
                        .scaleEffect(1.7)
                }

                ForEach(Array(webDomainTokens), id: \.self) { token in
                    Label(token)
                        .labelStyle(.iconOnly)
                        .scaleEffect(1.7)
                }

                ForEach(Array(categoryTokens), id: \.self) { token in
                    Label(token)
                        .labelStyle(.iconOnly)
                        .scaleEffect(1.2) // For some reason category tokens are slightly larger
                }
            }
        }
    }
}

struct BoundaryDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BoundaryDetailsView(selectedLimit: .constant(nil), allLimits: .constant([]), modifiedLimits: .constant([]), isPresented: .constant(true))
        }
    }
}
