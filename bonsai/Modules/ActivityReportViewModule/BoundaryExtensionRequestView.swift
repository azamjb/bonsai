import SwiftUI

struct BoundaryExtensionRequestView: View {
    @StateObject private var viewModel = AccountabilityPartnerViewModel()
    @StateObject var UserViewModel: ProfileViewModel = ProfileViewModel()
    @EnvironmentObject var screenTime: ScreenTimeService

    @State public var checkedItems: [Boundary: Bool] = [:]
    @State var isRequestSent: Bool = false
    @State public var sentExtensionBoundaryNames: [String] = []
    @State private var requestNote: String = ""
    @State private var pin: String = ""

    @FocusState private var isFieldFocused: Bool

    @AppStorage("hasAccountabilityPartner") var hasAccountabilityPartner: Bool = false
    @State public var showNoBoundariesSelectedError: Bool = false
    @State public var showRequestAlreadySentError: Bool = false

    var body: some View {
        if !hasAccountabilityPartner {
            noAccountabilityPartnerView(hasAccountabilityPartner: $hasAccountabilityPartner)
        } else {
            BoundaryExtensionRequestMainView(
                viewModel: viewModel,
                userViewModel: UserViewModel,
                checkedItems: $checkedItems,
                isRequestSent: $isRequestSent,
                sentExtensionBoundaryNames: $sentExtensionBoundaryNames,
                requestNote: $requestNote,
                pin: $pin,
                isFieldFocused: $isFieldFocused,
                showNoBoundariesSelectedError: $showNoBoundariesSelectedError,
                showRequestAlreadySentError: $showRequestAlreadySentError
            )
        }
    }
}

struct BoundaryExtensionRequestMainView: View {
    @ObservedObject var viewModel: AccountabilityPartnerViewModel
    @ObservedObject var userViewModel: ProfileViewModel
    @EnvironmentObject var screenTime: ScreenTimeService

    @Binding var checkedItems: [Boundary: Bool]
    @Binding var isRequestSent: Bool
    @Binding var sentExtensionBoundaryNames: [String]
    @Binding var requestNote: String
    @Binding var pin: String
    @FocusState.Binding var isFieldFocused: Bool

    @Binding var showNoBoundariesSelectedError: Bool
    @Binding var showRequestAlreadySentError: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                scrollContent
            }
            .onAppear(perform: setupOnAppear)
            .onChange(of: screenTime.boundariesReached) { _, newBoundaries in
                updateCheckedItems(newBoundaries)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Broken up views

    private var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading) {
                headerSection
                selectSection
                noteSection
                actionSection
                statusSection
                enterCodeSection
                sentCodesSection
            }
            .padding(.horizontal, 40)
        }
        .onTapGesture { hideKeyboard() }
    }

    private var headerSection: some View {
        VStack {
            Spacer()

            HStack { Spacer(); HeaderView(); Spacer() }

            HStack {
                Spacer()
                Image("lanterns")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                Spacer()
            }
        }
    }

    private var selectSection: some View {
        SelectAppsSection(
            screenTime: screenTime,
            checkedItems: $checkedItems,
            showErrorMessage: $showNoBoundariesSelectedError
        )
    }

    private var noteSection: some View {
        NoteSection(requestNote: $requestNote, isFieldFocused: $isFieldFocused)
    }

    private var actionSection: some View {
        HStack {
            SendCodeButton(
                viewModel: viewModel,
                userViewModel: userViewModel,
                requestNote: $requestNote,
                checkedItems: $checkedItems,
                showErrorMessage: $showNoBoundariesSelectedError,
                isRequestSent: $isRequestSent,
                showRequestAlreadySentError: $showRequestAlreadySentError,
                sentExtensionBoundaryNames: $sentExtensionBoundaryNames
            )

            NavigationLink(destination: OverrideBoundaryView(screenTime)) {
                Text("override")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 24)
                    .background(RoundedRectangle(cornerRadius: 15).fill(Color.black))
                    .padding(.bottom, 30)
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var statusSection: some View {
        if showNoBoundariesSelectedError {
            HStack {
                Spacer()
                Text("Please select at least one boundary.")
                    .foregroundColor(.red)
                Spacer()
            }
        }

        if isRequestSent{
            HStack {
                Spacer()
                Text("Extension code has been sent")
                    .foregroundColor(.green)
                Spacer()
            }
        }

        if showRequestAlreadySentError {
            HStack {
                Text("One or more selected boundaries already have an active extension code for today.")
                    .foregroundColor(.red)
                Spacer()
            }
        }
    }

    @ViewBuilder
    private var enterCodeSection: some View {
        if isRequestSent || viewModel.isAnyCodeActive() {
            EnterCodeSection(
                pin: $pin,
                checkedItems: $checkedItems,
                viewModel: viewModel,
                screenTime: screenTime,
                isRequestSent: $isRequestSent,
                sentExtensionBoundaryNames: $sentExtensionBoundaryNames
            )
        }
    }

    private var sentCodesSection: some View {
        SentRequestCodesSection(
            sentExtensionRequests: screenTime.getSentExtensionCodesAsBoundaryNameAndDateDict()
        )
    }

    // MARK: - Existing functions
    private func setupOnAppear() {
        userViewModel.fetchUserProfile()

        screenTime.setGroupDisplays()
        for boundary in screenTime.boundariesReached {
            if checkedItems[boundary] == nil {
                checkedItems[boundary] = false
            }
        }
    }

    private func updateCheckedItems(_ newBoundaries: [Boundary]) {
        for boundary in newBoundaries {
            if checkedItems[boundary] == nil {
                checkedItems[boundary] = false
            }
        }

        let allKeys = Set(checkedItems.keys)
        let newSet = Set(newBoundaries)

        for oldKey in allKeys.subtracting(newSet) {
            checkedItems.removeValue(forKey: oldKey)
        }
    }
}

// MARK: - Component Views
struct HeaderView: View {
    var body: some View {
        
        VStack(alignment: .center, spacing: 8) {
           

            Text("BOUNDARY EXTENSION")
                .bold()
                .font(.system(size: 25))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
        }
        .padding(.top, 40)
    }
}

private struct noAccountabilityPartnerView: View {
    @State private var pin: String = ""
    @State private var wrongCodeEntered = false
    @State private var navigateToProfileCreation4 = false
    @State private var triggerSuccess = false

    let smsApi = SMSApi()
    @ObservedObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()
    @AppStorage("invitedAccountabilityPartner") var invitedAccountabilityPartner: Bool = false
    @Binding var hasAccountabilityPartner: Bool

    var body: some View {
        ScrollView {
            VStack {
                Text("You need to have an Accountability Partner in order to use this feature")
                    .font(.system(size: 19))
                    .padding(.bottom, 35)
                    .padding(.top, 130)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)

                if invitedAccountabilityPartner {
                    Group {
                        Text("We have sent your partner an invite containing a verification code, enter this code below to validate your partner")
                            .font(.system(size: 19))
                            .padding(.bottom, 40)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        SixDigitCodeField(code: $pin)
                            .padding(.bottom, 30)
                        
                        Button {
                            handleInviteCodeValidation(pin: pin)
                            pin = ""
                        } label: {
                            Text("validate")
                                .font(.system(size: 15))
                                .foregroundColor(.primary)
                                .padding(.vertical, 15)
                                .padding(.horizontal, 80)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(wrongCodeEntered ? Color.red : Color.primary, lineWidth: 1)
                                )
                        }
                        .padding(.bottom, 20)
                    }
                }

                Button(action: {
                    navigateToProfileCreation4 = true
                }) {
                    Text("Send a New Invite")
                        .foregroundColor(.blue)
                        .font(.system(size: 15))
                        .underline()
                        .frame(alignment: .leading)
                }

                Spacer(minLength: 200)
            }
            .padding(.horizontal, 35)
            .background(Color.white.opacity(0.0001))
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationDestination(isPresented: $navigateToProfileCreation4) {
            ProfileCreation4View()
        }
        .onChange(of: triggerSuccess) { _, newValue in
            if newValue {
                hasAccountabilityPartner = true
            }
        }
    }

    @MainActor
    private func handleInviteCodeValidation(pin: String) {
        let inviteCode = UserDefaults.standard.string(forKey: "AccountabilityPartnerInviteCode")
        let accountabilityPartnerPhone = UserDefaults.standard.string(forKey: "tempAccountabilityPartnerNumber") ?? ""
        let accountabilityPartnerName = UserDefaults.standard.string(forKey: "tempAccountabilityPartnerName") ?? ""

        if pin == inviteCode {
            Task {
                await viewModel.saveAccountabilityPartner(
                    name: accountabilityPartnerName,
                    phoneNumber: accountabilityPartnerPhone
                )

                UserDefaults.standard.removeObject(forKey: "tempAccountabilityPartnerNumber")
                UserDefaults.standard.removeObject(forKey: "tempAccountabilityPartnerName")

                // Add a small delay to allow Screen Time service to stabilize
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                DispatchQueue.main.async {
                    triggerSuccess = true
                }
                
                let SMSInvite = SMSInvite(
                    number: viewModel.accountabilityPartner.phoneNumber ?? "",
                    username: viewModel.userProfile.name ?? "",
                    accountabilityPartnerName: viewModel.accountabilityPartner.name ?? "", code: ""
                )
                
                try await smsApi.introduction(request: SMSInvite)
            }
        } else {
            wrongCodeEntered = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                wrongCodeEntered = false
            }
        }
    }
}

struct SelectAppsSection: View {
    @ObservedObject var screenTime: ScreenTimeService
    @Binding var checkedItems: [Boundary: Bool]
    @Binding var showErrorMessage: Bool

    var body: some View {
        VStack {
            Text("SELECT BOUNDARIES")
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 6)
                .foregroundStyle(.primary)

            if !screenTime.boundariesReached.isEmpty {
                VStack(alignment: .leading) {
                    ForEach(screenTime.boundariesReached, id: \.id) { Boundary in
                        let isCheckedBinding = Binding<Bool>(
                            get: {
                                checkedItems[Boundary] ?? false
                            },
                            set: { newValue in
                                checkedItems[Boundary] = newValue
                            }
                        )

                        CheckboxView(
                            isChecked: isCheckedBinding,
                            showErrorMessage: $showErrorMessage,
                            label: Boundary.givenName
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                Text("You haven't hit any boundaries today.")
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct NoteSection: View {
    @Binding var requestNote: String
    @FocusState.Binding var isFieldFocused: Bool

    var body: some View {
        VStack(spacing: 16) {
            TextField("Add a note...", text: $requestNote)
                .modifier(CustomTextFieldStyle2(placeholder: ""))
                .frame(minHeight: 50)
                .focused($isFieldFocused)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 30)
    }
}

struct SendCodeButton: View {
    @ObservedObject var viewModel: AccountabilityPartnerViewModel
    @ObservedObject var userViewModel: ProfileViewModel
    @Binding var requestNote: String
    @Binding var checkedItems: [Boundary: Bool]
    @Binding var showErrorMessage: Bool
    @Binding var isRequestSent: Bool
    @Binding var showRequestAlreadySentError: Bool
    @Binding var sentExtensionBoundaryNames: [String]
    
    var body: some View {
        VStack {
            Button {
                if checkedItems.filter({ $0.value }).isEmpty {
                    showErrorMessage = true
                    isRequestSent = false
                } else {
                    isRequestSent = false
                    showErrorMessage = false
                    
                    Task {
                        let boundaries = checkedItems.filter { $0.value }.map { $0.key }
                        
                        guard shouldSendExtensionRequest(boundaries: boundaries) else {
                            return
                        }
                        
                        await viewModel.sendTimeRequest(
                            phoneNumber: userViewModel.accountabilityPartner.phoneNumber ?? "",
                            userName: userViewModel.userProfile.name ?? "",
                            accountabilityPartnerName: userViewModel.accountabilityPartner.name ?? "",
                            note: requestNote,
                            boundaries: boundaries
                        )
                        
                        isRequestSent = true
                        requestNote = ""
                    }
                }
            } label: {
                Text("send request")
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 40)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.primary, lineWidth: 1)
                    )
                    .padding(.bottom, 30)
            }
        }
    }
    
    private func shouldSendExtensionRequest(boundaries: [Boundary]) -> Bool {
        let alreadyHasCode = boundaries.filter { !doesActiveCodeExistForBoundary(boundaryId: $0.id) }.count > 0

        if alreadyHasCode {
            showRequestAlreadySentError = true
            return false
        }

        showRequestAlreadySentError = false

        let foundBoundaryNames = boundaries.map(\.givenName)
        sentExtensionBoundaryNames.append(contentsOf: foundBoundaryNames)

        return true
    }

    private func doesActiveCodeExistForBoundary(boundaryId: UUID) -> Bool {
        let sentExtensionCodeService = SentExtensionCodeService(storage: SentExtensionCodeStorageService(database: LocalDatabase.shared.databaseWriter))
        
        let code = sentExtensionCodeService.getRecentSentExtensionCodeForBoundary(boundaryId: boundaryId)
        
        // if the code is still valid we shouldn't allow them to send another one
        if (code != nil && code!.isCodeValid) {
            return false
        }
        
        return true
    }
}

struct SentRequestCodesSection: View {
    var sentExtensionRequests: [(String, Date)]
    
    var body: some View {
        VStack {
            Divider()
                .frame(height: 1)
                .background(Color.primary)
                .padding(.top, 10)
                .padding(.bottom, 10)

            VStack {
                Text("SENT REQUEST CODES")
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 12)
                    .foregroundStyle(.primary)
                
                VStack {
                    if sentExtensionRequests.count == 0 {
                        Text("You haven't sent your partner any codes yet.")
                            .font(.system(size: 15))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 20)
                    } else {
                        ScrollView {
                            ForEach(0..<sentExtensionRequests.count, id: \.self) { index in
                                let (name, date) = sentExtensionRequests[index]
                                VStack(alignment: .leading) {
                                    Text(name)
                                        .bold()
                                    
                                    Text(mediumDateTimeFormat(date: date))
                                        .foregroundStyle(.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 10)
                            }
                        }
                        .frame(maxHeight: 300)
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }
}

struct EnterCodeSection: View {
    @Binding var pin: String
    @Binding var checkedItems: [Boundary: Bool]
    @State private var showSuccessAlert = false
    @State private var showFailureAlert = false
    @ObservedObject var viewModel: AccountabilityPartnerViewModel
    @ObservedObject var screenTime: ScreenTimeService
    @Binding var isRequestSent: Bool
    @Binding var sentExtensionBoundaryNames: [String]

    var body: some View {
        VStack {
            Divider()
                .frame(height: 1)
                .background(Color.primary)
                .padding(.top, 10)
                .padding(.bottom, 10)

            Text("ENTER REQUEST CODE")
                .font(.system(size: 15))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 60)

            SixDigitCodeField(code: $pin)
                .padding(.bottom, 30)

            Button {
                handleCodeValidation()
            } label: {
                Text("enter code")
                    .font(.system(size: 15))
                    .foregroundColor(.primary)
                    .padding(.vertical, 15)
                    .padding(.horizontal, 80)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.primary, lineWidth: 1)
                    )
            }
            .padding(.bottom, 20)
        }
        .alert("Code Validated", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Screen time has been extended successfully.")
        }
        .alert("Invalid Code", isPresented: $showFailureAlert) {
            Button("Try Again", role: .cancel) {}
        } message: {
            Text("The verification code you entered is not valid.")
        }
    }

    private func handleCodeValidation() {
        Task {
            let validated = viewModel.validateVerificationCode(pin: pin)
            
            if validated {
                if validated {
                    pin = ""
                    showSuccessAlert = true
                    isRequestSent = false

                    for key in checkedItems.keys { checkedItems[key] = false }

                    screenTime.setGroupDisplays()
                }
            } else {
                showFailureAlert = true
            }
        }
    }
}


struct CheckboxView: View {
    @Binding var isChecked: Bool
    @Binding var showErrorMessage: Bool
    let label: String

    var body: some View {
        HStack {
            Image(systemName: isChecked ? "checkmark.square" : "square")
                .font(.system(size: 20))
                .onTapGesture {
                    isChecked.toggle()
                    showErrorMessage = false
                }
            Text(label)
                .font(.system(size: 15))
                .onTapGesture {
                    isChecked.toggle()
                    showErrorMessage = false
                }
        }
        .contentShape(Rectangle())
        .padding(.top, 5)
    }
}

struct CustomTextFieldStyle2: ViewModifier {
    let placeholder: String

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(placeholder)
                .foregroundColor(.secondary)
                .font(.system(size: 13))

            content
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(height: 120)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    BoundaryExtensionRequestView()
}
