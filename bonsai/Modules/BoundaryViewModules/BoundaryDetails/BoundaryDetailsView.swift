//
//  BoundaryDetailsView.swift
//  bonsai
//
//  Created by Brayden O on 2025-03-09.
//

import SwiftUI
import FamilyControls
import ManagedSettings

struct BoundaryDetailsView: View {
    @Binding var selectedBoundary: Boundary?
    @Binding var allBoundaries: [Boundary]
    @Binding var modifiedBoundaries: [Boundary]
    @Binding var isPresented: Bool
    @Binding var boundariesBeingDeleted: [Boundary?]
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var boundaryToUse: Boundary
    @State private var isNewBoundary: Bool
    @State private var deepCopiedExistingBoundary: Boundary?
    @State private var isShowingFamilyActivityPicker: Bool = false
    @State private var activitySelection: FamilyActivitySelection = FamilyActivitySelection()
    @EnvironmentObject var screenTime: ScreenTimeService
   
    @State private var errorMessage: String? = nil
    @State private var submitAttempted: Bool = false

    init(selectedBoundary: Binding<Boundary?>,
         allBoundaries: Binding<[Boundary]>,
         modifiedBoundaries: Binding<[Boundary]>,
         isPresented: Binding<Bool>,
         boundariesBeingDeleted: Binding<[Boundary?]>
    ) {
        self._selectedBoundary = selectedBoundary
        self._allBoundaries = allBoundaries
        self._modifiedBoundaries = modifiedBoundaries
        self._isPresented = isPresented
        self._boundariesBeingDeleted = boundariesBeingDeleted
        
        let defaultBoundary = Boundary(
            id: UUID(),
            givenName: "Unnamed Boundary",
            appTokens: [],
            categoryTokens: [],
            webDomainTokens: [],
            hours: 0,
            minutes: 15,
            weekdays: [],
            invisibleBoundary: false)
        
        if let currentBoundary = selectedBoundary.wrappedValue {
            self._boundaryToUse = State(initialValue: currentBoundary)
            deepCopiedExistingBoundary = DeepCopy(currentBoundary)

            isNewBoundary = false
            
            var tempSelection = FamilyActivitySelection()
            tempSelection.applicationTokens = currentBoundary.appTokens
            tempSelection.categoryTokens = currentBoundary.categoryTokens
            tempSelection.webDomainTokens = currentBoundary.webDomainTokens
            self._activitySelection = State(initialValue: tempSelection)
        } else {
            self._boundaryToUse = State(initialValue: defaultBoundary)
            
            isNewBoundary = true
        }
    }
    
    var body: some View {
        VStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                Text("Boundary Details")
                    .font(.system(size: 30))
                    .multilineTextAlignment(.center)
                    .padding(.top, 80)
                
                VStack(spacing: 15) {
                    NavigationLink(destination: BoundaryLabelEditor(boundary: $boundaryToUse)) {
                        HStack {
                            Text("BOUNDARY LABEL")
                            Spacer()
                            Text(boundaryToUse.givenName.shorted(to: 10))
                                .lineLimit(1)
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .contentShape(Rectangle())
                    }
                    .foregroundStyle(.primary)
                    Divider().padding(.leading, 16)

                    NavigationLink(destination: DaysActiveEditor(boundary: $boundaryToUse)) {
                        HStack {
                            Text("DAYS ACTIVE")
                            Spacer()
                            DaysView(days: boundaryToUse.weekdays)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .contentShape(Rectangle())
                    }
                    .foregroundStyle(.primary)
                    Divider().padding(.leading, 16)

                    NavigationLink(destination: TimeBoundaryEditor(boundary: $boundaryToUse)) {
                        HStack {
                            Text("DAILY LIMIT")
                            Spacer()
                            Text("\(boundaryToUse.hours) hrs, \(boundaryToUse.minutes) mins")
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                                .padding(.leading, 4)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .contentShape(Rectangle())
                    }
                    .foregroundStyle(.primary)
                }
                .padding(.vertical, 15)
                .background(Color(UIColor.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .padding()
                
                Spacer()
                
                HStack {
                    Button(action: {
                        isShowingFamilyActivityPicker = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("SELECTED APPS")
                                    .foregroundColor(.primary)
                                
                                if activitySelection.applicationTokens.isEmpty
                                    && activitySelection.categoryTokens.isEmpty
                                    && activitySelection.webDomainTokens.isEmpty
                                {
                                    Text("No apps selected")
                                        .foregroundColor(Color.secondary)
                                        .padding(.vertical, 5)
                                } else {
                                    SelectedAppDisplay(
                                        appTokens: $activitySelection.applicationTokens,
                                        categoryTokens: $activitySelection.categoryTokens,
                                        webDomainTokens: $activitySelection.webDomainTokens
                                    )
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(Color.primary)
                        }
                    }
                }
                .padding(.horizontal, 45)

                Spacer()

                VStack {
                    VStack {
                        if let msg = errorMessage {
                            Text(msg)
                                .foregroundStyle(Color(UIColor.systemRed))
                                .padding(.horizontal)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(height: 40)
                    .padding(.horizontal, 45)
                    
                    VStack(spacing: 15) {
                        BonsaiButtonRegular(buttonText: "save") {
                            submitAttempted = true
                            
                            validateBoundary()
                            
                            if errorMessage == nil {
                                boundaryToUse.appTokens = activitySelection.applicationTokens
                                boundaryToUse.categoryTokens = activitySelection.categoryTokens
                                boundaryToUse.webDomainTokens = activitySelection.webDomainTokens
                                
                                if !isNewBoundary {
                                    if let index = allBoundaries.firstIndex(where: { $0.id == boundaryToUse.id }) {
                                        allBoundaries[index] = boundaryToUse
                                    }
                                } else {
                                    if allBoundaries.contains(where: { $0.id == boundaryToUse.id }) {
                                        boundaryToUse.id = UUID() // Create a new UUID if there's a conflict
                                    }
                                    
                                    allBoundaries.append(boundaryToUse)
                                }
                                
                                if !modifiedBoundaries.contains(where: { $0.id == boundaryToUse.id }) {
                                    modifiedBoundaries.append(boundaryToUse)
                                } else {
                                    if let index = modifiedBoundaries.firstIndex(where: { $0.id == boundaryToUse.id }) {
                                        modifiedBoundaries[index] = boundaryToUse
                                    }
                                }
                                
                                isPresented = false
                            }
                        }
                        
                        BonsaiButtonRegular(buttonText: "cancel") {
                            if !isNewBoundary {
                                boundaryToUse = deepCopiedExistingBoundary!
                            }
                            
                            isPresented = false
                        }
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 40)
                }
            }
        }
        .familyActivityPicker(isPresented: $isShowingFamilyActivityPicker, selection: $activitySelection)
        .onChange(of: activitySelection) { _, newSelection in
            if submitAttempted {
                validateBoundary()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func validateBoundary() {
        if activitySelection.applicationTokens.isEmpty && activitySelection.categoryTokens.isEmpty && activitySelection.webDomainTokens.isEmpty {
            errorMessage = "Please make at least one selection from app picker."
        } else if selectedTokensAreUnique() {
            errorMessage = "At least one selection already exists in another boundary."
        } else if boundaryToUse.weekdays.isEmpty {
            errorMessage = "Please select at least one weekday."
        } else {
            errorMessage = nil
        }
    }
    
    private func selectedTokensAreUnique() -> Bool {
        return screenTime.boundariesSet.filter({ boundary in boundary.id != boundaryToUse.id && !boundariesBeingDeleted.map({ $0?.id }).contains(boundary.id) }).contains(where: { boundary in
            let hasMatchingAppTokens = !$activitySelection.applicationTokens.wrappedValue.isDisjoint(with: boundary.appTokens)
            let hasMatchingCategoryTokens = !$activitySelection.categoryTokens.wrappedValue.isDisjoint(with: Set(boundary.categoryTokens))
            let hasMatchingWebDomainTokens = !$activitySelection.webDomainTokens.wrappedValue.isDisjoint(with: Set(boundary.webDomainTokens))
            
            return hasMatchingAppTokens || hasMatchingCategoryTokens || hasMatchingWebDomainTokens
        })
    }
    
}

private struct DaysView: View {
    let days: Set<Weekday>
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(Weekday.allCases, id: \.self) { day in
                ZStack {
                    Circle()
                        .fill(days.contains(day) ? Color.gray : .clear)
                        .frame(width: 20, height: 24)
                    
                    Text(day.label)
                        .font(.system(size: 15))
                        .fontWeight(.medium)
                        .foregroundColor(days.contains(day) ? Color.primary : Color.secondary)
                }
            }
        }
    }
}

// MARK: - Boundary Label Editor
private struct BoundaryLabelEditor: View {
    @Binding var boundary: Boundary
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isFocused: Bool

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
                if boundary.givenName.isEmpty {
                    boundary.givenName = "Unnamed Boundary"
                }
                
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
        BonsaiTextField(binding: $boundary.givenName, placeholder: "Unnamed Boundary", title: "BOUNDARY NAME")
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
    }
}

// MARK: - Days Active Editor
private struct DaysActiveEditor: View {
    @Binding var boundary: Boundary
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
                            .fill(boundary.weekdays.contains(day) ? Color.secondary : Color.clear)
                    )
                    .frame(width: 24, height: 24)
                
                Text(day.fullName)
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
        if boundary.weekdays.contains(day) {
            boundary.weekdays.remove(day)
        } else {
            boundary.weekdays.insert(day)
        }
        
        if let onSave = onSave {
            onSave()
        }
    }
}

// MARK: - Time Boundary Editor
private struct TimeBoundaryEditor: View {
    @Binding var boundary: Boundary
    @Environment(\.presentationMode) var presentationMode
    @State private var pickerMinutes: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            headerView()
            boundarySelectorView()
            
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
    
    private func boundarySelectorView() -> some View {
        VStack {
            VStack(alignment: .leading, spacing: 10) {
                Text("DAILY LIMIT")
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 15)
                    .background(Color(UIColor.systemGray5))
                
                HStack {
                    Picker("", selection: $boundary.hours){
                        ForEach(0..<8, id: \.self) { i in
                            Text("\(i) hours").tag(i)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    
                    Picker("", selection: $boundary.minutes){
                        ForEach(0..<60, id: \.self) { i in
                            Text("\(i) mins")
                                .tag(i)
                                .foregroundColor(boundary.hours == 0 && i < 15 ? .gray : .primary)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .onChange(of: boundary.minutes) { _, newValue in
                        if boundary.hours == 0 && newValue < 15 {
                            boundary.minutes = 15
                        }
                    }
                }
                .padding(.horizontal)
            }
            .background(Color(UIColor.systemGray5))
            .cornerRadius(10)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Selected app display
private struct SelectedAppDisplay: View {
    @Binding var appTokens: Set<ApplicationToken>
    @Binding var categoryTokens: Set<ActivityCategoryToken>
    @Binding var webDomainTokens: Set<WebDomainToken>
    
    private struct IdentifiableToken: Identifiable {
        let id = UUID()
        let token: Any
    }
    
    private var allTokens: [IdentifiableToken] {
        let apps = appTokens.map { IdentifiableToken(token: $0) }
        let domains = webDomainTokens.map { IdentifiableToken(token: $0) }
        let categories = categoryTokens.map { IdentifiableToken(token: $0) }
        return apps + domains + categories
    }
    
    private var totalCount: Int {
        allTokens.count
    }
    
    private var maxDisplayCount: Int {
       8
    }
    
    private var shouldShowEllipses: Bool {
        totalCount > maxDisplayCount
    }
    
    private var tokensToShow: [IdentifiableToken] {
        shouldShowEllipses ? Array(allTokens.prefix(maxDisplayCount)) : allTokens
    }

    var body: some View {
        HStack(spacing: -5) {
            ForEach(tokensToShow) { identifiableToken in
                tokenView(for: identifiableToken.token)
            }
            
            if shouldShowEllipses {
                ellipsesView
            }
        }
    }
    
    @ViewBuilder
    private func tokenView(for token: Any) -> some View {
        if let appToken = token as? ApplicationToken {
            appTokenView(appToken)
        } else if let webToken = token as? WebDomainToken {
            webTokenView(webToken)
        } else if let categoryToken = token as? ActivityCategoryToken {
            categoryTokenView(categoryToken)
        }
    }
    
    private func appTokenView(_ token: ApplicationToken) -> some View {
        Label(token)
            .labelStyle(.iconOnly)
            .scaleEffect(1.7)
    }
    
    private func webTokenView(_ token: WebDomainToken) -> some View {
        Label(token)
            .labelStyle(.iconOnly)
            .scaleEffect(1.2)
    }
    
    private func categoryTokenView(_ token: ActivityCategoryToken) -> some View {
        Label(token)
            .labelStyle(.iconOnly)
            .scaleEffect(1.2) // For some reason category tokens are slightly larger
    }
    
    private var ellipsesView: some View {
        Text("...")
            .foregroundColor(.secondary)
            .bold()
            .padding(.leading, 10)
            .padding(.top, 10)
    }
}

struct BoundaryDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            BoundaryDetailsView(selectedBoundary: .constant(nil), allBoundaries: .constant([]), modifiedBoundaries: .constant([]), isPresented: .constant(true), boundariesBeingDeleted: .constant([]))
        }
    }
}
