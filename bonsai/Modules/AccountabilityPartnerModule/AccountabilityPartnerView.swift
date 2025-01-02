import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings

struct AccountabilityPartnerView: View {
    @StateObject private var model = ScreenTimeSelectAppsModel.shared
    let smsApi = SMSApi()
    @State private var phoneNumber: String = ""
    @State private var code: String = ""
    @State private var userCode: String = ""
    @State private var isValidated = false
    @State private var isSendInvitePressed = false
    @State private var isRequestMoreTimePressed = false
    @State private var verificationMessage: String? = nil

    func generateRandomCode() -> String {
        let randomCode = Int.random(in: 100_000...999_999)
        return String(randomCode)
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Accountability")
                        .font(.largeTitle)

                    Text("Invite Partner")
                        .font(.title)
                        .fontWeight(.semibold)
                        .padding(.top, 16)

                    // Phone Number Input
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        .frame(height: 50)
                        .overlay(
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.blue)

                                // TextField for phone number
                                TextField("Phone Number", text: $phoneNumber)
                                    .keyboardType(.phonePad)
                                    .padding(.leading, 4)
                            }
                            .padding(.horizontal)
                        )

                    // Submit button
                    Button(action: {
                        UIApplication.shared.dismissKeyboard()
                        Task {
                            code = generateRandomCode()
                            try await smsApi.invite(
                                request: SMSRequest(
                                    number: phoneNumber,
                                    username: "Azam",
                                    accountabilityPartnerName: "Bob",
                                    code: code
                                )
                            )
                            isSendInvitePressed = true
                        }
                    }) {
                        Text("Send Invite")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background( Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    if !phoneNumber.isEmpty && isSendInvitePressed {
                        Text("Enter verification code")
                            .font(.title)
                            .fontWeight(.semibold)
                            .padding(.top, 16)

                        // Verification Input
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            .frame(height: 50)
                            .overlay(
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.blue)

                                    TextField("PIN", text: $userCode)
                                        .keyboardType(.phonePad)
                                        .padding(.leading, 4)
                                }
                                .padding(.horizontal)
                            )

                        // Verify button
                        Button(action: {
                            UIApplication.shared.dismissKeyboard()
                            if userCode == code {
                                isValidated = true
                                verificationMessage = "Verification Successful!"
                            } else {
                                isValidated = false
                                verificationMessage = "Invalid Code. Please try again."
                            }
                        }) {
                            Text("Verify")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        // Verification feedback
                        if let message = verificationMessage {
                            Text(message)
                                .font(.headline)
                                .foregroundColor(isValidated ? .green : .red)
                                .padding(.top, 8)
                        }
                    }

                    Spacer()

                    if isValidated {
                        Button(action: {
                            UIApplication.shared.dismissKeyboard()
                            Task {
                                try await smsApi.timeRequest(
                                    request: SMSRequest(
                                        number: phoneNumber,
                                        username: "Azam",
                                        accountabilityPartnerName: "Bob",
                                        code: "123432"
                                    )
                                )
                            }
                        }) {
                            Text("Request More Time")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(isRequestMoreTimePressed ? Color.blue.opacity(0.7) : Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .onTapGesture {
                UIApplication.shared.dismissKeyboard() // Dismiss keyboard when tapping outside
            }
        }
    }
}
