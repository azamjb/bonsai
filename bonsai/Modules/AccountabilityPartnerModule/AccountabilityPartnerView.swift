import SwiftUI
import iPhoneNumberField
import FamilyControls
import DeviceActivity
import ManagedSettings

struct AccountabilityPartnerView: View {
    @StateObject private var viewModel = AccountabilityPartnerViewModel()

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
                                iPhoneNumberField("Phone Number", text: $viewModel.phoneNumber)
                                    .keyboardType(.phonePad)
                                    .padding(.leading, 4)
                            }
                            .padding(.horizontal)
                        )

                    // Submit button
                    Button(action: {
                        Task {
                            UIApplication.shared.dismissKeyboard()
                            await viewModel.sendTimeRequest()
                        }
                    }) {
                        if viewModel.isSendingText {
                            ProgressView()
                        } else {
                            Text("Send Invite")
                                .font(.headline)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isSendingText ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(viewModel.isSendingText)
                    
                    if !viewModel.errorMessage.isEmpty {
                        Text(viewModel.errorMessage)
                            .font(.headline)
                            .foregroundColor(viewModel.isValidated ? .green : .red)
                            .padding(.top, 8)
                    }

                    if !viewModel.phoneNumber.isEmpty && viewModel.isSendInvitePressed {
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

                                    TextField("PIN", text: $viewModel.userCode)
                                        .keyboardType(.phonePad)
                                        .padding(.leading, 4)
                                }
                                .padding(.horizontal)
                            )

                        // Verify button
                        Button(action: {
                            UIApplication.shared.dismissKeyboard()
                            if viewModel.userCode == viewModel.code {
                                viewModel.isValidated = true
                                viewModel.verificationMessage = "Verification Successful!"
                            } else {
                                viewModel.isValidated = false
                                viewModel.verificationMessage = "Invalid Code. Please try again."
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
                        if let message = viewModel.verificationMessage {
                            Text(message)
                                .font(.headline)
                                .foregroundColor(viewModel.isValidated ? .green : .red)
                                .padding(.top, 8)
                        }
                    }

                    Spacer()

                    if viewModel.isValidated {
                        Button(action: {
                            Task {
                                UIApplication.shared.dismissKeyboard()
                                await viewModel.sendTimeRequest()
                            }
                        })
                        {
                            Text("Request More Time")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(viewModel.isRequestMoreTimePressed ? Color.blue.opacity(0.7) : Color.blue)
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
