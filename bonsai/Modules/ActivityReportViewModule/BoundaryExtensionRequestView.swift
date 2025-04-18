import SwiftUI

struct BoundaryExtensionRequestView: View {
    
    
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
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Request")
                                .font(.title2)
                                .foregroundStyle(.primary)

                            Text("Boundary Extension")
                                .font(.title2)
                                .foregroundStyle(.primary)
                        }
                        .padding(.bottom, 40)
                        
                        VStack {
                            Text("SELECT APPS")
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 6)
                                .foregroundStyle(.primary)

                            if !screenTime.boundariesReached.isEmpty {
                                VStack(alignment: .leading) {
                                    ForEach(screenTime.boundariesReached, id: \.id) { boundary in
                                        let isCheckedBinding = Binding<Bool>(
                                            get: {
                                                checkedItems[boundary] ?? false
                                            },
                                            set: { newValue in
                                                // Update the dictionary
                                                checkedItems[boundary] = newValue
                                            }
                                        )
                                                            
                                        CheckboxView(
                                            isChecked: isCheckedBinding,
                                            label: boundary.givenName
                                        )
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            
                            else {
                                Text("You haven't hit any boundaries today.")
                                    .font(.system(size: 15))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        VStack(spacing: 16) {
                            TextField("Add a note...", text: $requestNote)
                                .modifier(CustomTextFieldStyle2(placeholder: ""))
                                .frame(minHeight: 50)
                                .focused($isFieldFocused)
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 30)
                        
                        Button(action: {
                            Task {
                                await viewModel.sendTimeRequest(phoneNumber: UserViewModel.userProfile.accountabilityPartner?.phoneNumber ?? "",
                                                                userName: UserViewModel.userProfile.name, accountabilityPartnerName: UserViewModel.userProfile.accountabilityPartner?.name ?? "", note: requestNote)
                                requestNote = "" // reset note
                            }
                        }) {
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
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color.primary)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        
                        VStack {
                            Text("SENT REQUEST CODES")
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 6)
                                .foregroundStyle(.primary)
                            
                            Text("You haven't sent your partner any codes yet.")
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color.primary)
                            .padding(.top, 90)
                            .padding(.bottom, 10)
                        
                        Text("ENTER REQUEST CODE")
                            .font(.system(size: 15))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 60)
                        
                        PinEntryView(pin: $pin)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 50)
                         
                        Button(action: {
                            Task {
//                                let validated = viewModel.validateVerificationCode(Pin: pin) // see if the code entered by the user is valid
//                                
//                                if (validated) {
                                    for (boundary, isChecked) in checkedItems {
//                                        if (isChecked) { // if boundary is checked to be extended
                                            screenTime.extendBlockedBoundary(boundary: boundary) // extend time for that boundary
//                                            screenTime.setGroupDisplays()
//                                        }
                                    }
//                                    pin = ""
//                                    UserDefaults.standard.removeObject(forKey: LocalStorageKeys.timeExtensionRequestCode)
//
//                                }
//                                else {
//                                    print("invalid code")
//                                }
                            }
                        }) {
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
                    .padding(.horizontal, 40)
                }
          
                .onTapGesture {
                    hideKeyboard()
                }
                
            }
            .onAppear() {
                
                UserViewModel.fetchUserProfile()
                screenTime.setGroupDisplays()
                for boundary in screenTime.boundariesReached { // adding all boundaries to the dictionary, initially unchecked
                        if checkedItems[boundary] == nil {
                            checkedItems[boundary] = false
                        }
                    }
            }
            .onChange(of: screenTime.boundariesReached) { _, newBoundaries in
                for boundary in newBoundaries {
                    if checkedItems[boundary] == nil {
                        checkedItems[boundary] = false
                    }
                }
                let allKeys = Set(checkedItems.keys)
                let newSet  = Set(newBoundaries)
                for oldKey in allKeys.subtracting(newSet) {
                    checkedItems.removeValue(forKey: oldKey)
                }
            }
            
            
        }
        .customBackToolbar()
       
        
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
                .frame(height: 120) // Keep it a large text box
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    BoundaryExtensionRequestView()
}
