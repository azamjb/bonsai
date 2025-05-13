import SwiftUI

struct BoundaryExtensionRequestView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AccountabilityPartnerViewModel()
    @StateObject var UserViewModel: ProfileViewModel = ProfileViewModel()
    @State private var isRememberMeChecked = false
    @EnvironmentObject var screenTime: ScreenTimeService
    @State public var checkedItems: [Boundary : Bool] = [:] // dictionary to track which of the boundaries have been 'checked' to be extended

    @State private var requestNote: String = ""
    @State private var pin: String = ""
    @FocusState private var isFieldFocused: Bool
    @AppStorage("isProfileCreated") private var isProfileCreated = false

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        Spacer()
                        HeaderView()
                        SelectAppsSection(screenTime: screenTime, checkedItems: $checkedItems)
                        NoteSection(requestNote: $requestNote, isFieldFocused: _isFieldFocused)
                        SendCodeButton(viewModel: viewModel, userViewModel: UserViewModel, requestNote: $requestNote, checkedItems: $checkedItems)
                        EnterCodeSection(pin: $pin, checkedItems: checkedItems, viewModel: viewModel, screenTime: screenTime)
                        SentRequestCodesSection(sentExtensionRequestsThisWeek: screenTime.getSentExtensionRequestsThisWeek())
                    }
                    .padding(.horizontal, 40)
                }
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .onAppear {
                setupOnAppear()
            }
            .onChange(of: screenTime.boundariesReached) { _, newboundaries in
                updateCheckedItems(newboundaries)
            }
        }
        .customBackToolbar()
        .navigationBarBackButtonHidden(true)
    }

    private func setupOnAppear() {
        UserViewModel.fetchUserProfile()

        screenTime.setGroupDisplays()
        for Boundary in screenTime.boundariesReached {
            if checkedItems[Boundary] == nil {
                checkedItems[Boundary] = false
            }
        }
    }

    private func updateCheckedItems(_ newboundaries: [Boundary]) {
        for Boundary in newboundaries {
            if checkedItems[Boundary] == nil {
                checkedItems[Boundary] = false
            }
        }
        let allKeys = Set(checkedItems.keys)
        let newSet = Set(newboundaries)
        for oldKey in allKeys.subtracting(newSet) {
            checkedItems.removeValue(forKey: oldKey)
        }
    }
}

// MARK: - Component Views
struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Request")
                .font(.title2)
                .foregroundStyle(.primary)

            Text("Boundary Extension")
                .font(.title2)
                .foregroundStyle(.primary)
        }
        .padding(.bottom, 40)
    }
}

struct SelectAppsSection: View {
    @ObservedObject var screenTime: ScreenTimeService
    @Binding var checkedItems: [Boundary: Bool]

    var body: some View {
        VStack {
            Text("SELECT APPS")
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
    @FocusState var isFieldFocused: Bool

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
    
    var body: some View {
        Button {
            Task {
                await viewModel.sendTimeRequest(
                    phoneNumber: userViewModel.accountabilityPartner.phoneNumber ?? "",
                    userName: userViewModel.userProfile.name ?? "",
                    accountabilityPartnerName: userViewModel.accountabilityPartner.name ?? "",
                    note: requestNote,
                    boundaries: checkedItems.filter({ $0.value == true }).map({ $0.key })
                )
                requestNote = ""
            }
        } label: {
            Text("send code to partner")
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .padding(.vertical, 15)
                .padding(.horizontal, 80)
                .frame(maxWidth: .infinity, alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.primary, lineWidth: 1)
                )
        }
        .padding(.bottom, 30)
    }
}

struct SentRequestCodesSection: View {
    var sentExtensionRequestsThisWeek: [(String, Date)]
    
    var body: some View {
        VStack {
            Divider()
                .frame(height: 1)
                .background(Color.primary)
                .padding(.top, 10)
                .padding(.bottom, 10)

            VStack {
                Text("SENT REQUEST CODES TODAY")
                    .font(.system(size: 15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 12)
                    .foregroundStyle(.primary)
                
                VStack {
                    if sentExtensionRequestsThisWeek.count == 0 {
                        Text("You haven't sent your partner any codes yet.")
                            .font(.system(size: 15))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(0..<sentExtensionRequestsThisWeek.count, id: \.self) { index in
                            let (name, date) = sentExtensionRequestsThisWeek[index]
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
                }
                .frame(maxHeight: 300)
            }
        }
    }
}

struct EnterCodeSection: View {
    @Binding var pin: String
    let checkedItems: [Boundary: Bool]
    @State private var showSuccessAlert = false
    @State private var showFailureAlert = false
    @ObservedObject var viewModel: AccountabilityPartnerViewModel
    @ObservedObject var screenTime: ScreenTimeService

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

            PinEntryView(pin: $pin)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 50)

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
                pin = ""
                showSuccessAlert = true
            } else {
                print("invalid code")
                showFailureAlert = true
            }
        }
    }
}

struct PinEntryView: View {
    @Binding var pin: String
    @FocusState private var isPinFocused: Bool

    private let pinLength = 6

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<pinLength, id: \.self) { index in
                ZStack {
                    Text(pin.count > index ? String(pin[pin.index(pin.startIndex, offsetBy: index)]) : "")
                        .font(.title)
                        .foregroundColor(.primary)

                    Rectangle()
                        .frame(width: 30, height: 2)
                        .foregroundColor(.primary)
                        .offset(y: 20)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isPinFocused = true
        }
        .background(
            TextField("", text: $pin)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(width: 0, height: 0)
                .opacity(0)
                .focused($isPinFocused)
        )
    }
}

struct CheckboxView: View {
    @Binding var isChecked: Bool
    let label: String

    var body: some View {
        HStack {
            Image(systemName: isChecked ? "checkmark.square" : "square")
                .font(.system(size: 20))
                .onTapGesture {
                    isChecked.toggle()
                }
            Text(label)
                .font(.system(size: 15))
                .onTapGesture {
                    isChecked.toggle()
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
