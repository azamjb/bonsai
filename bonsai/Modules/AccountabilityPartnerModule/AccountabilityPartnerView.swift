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
                        UIApplication.shared.dismissKeyboard()
                        Task {
                            await viewModel.sendInvite()
                        }
                    }) {
                        if viewModel.isSendingInvite {
                            ProgressView()
                        } else {
                            Text("Send Invite")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(viewModel.isSendingInvite ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(viewModel.isSendingInvite)
                    
                    if !viewModel.inviteErrorMessage.isEmpty {
                        Text(viewModel.inviteErrorMessage)
                            .font(.headline)
                            .foregroundColor(.red)
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
                            viewModel.validateVerificationCode()
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
                            UIApplication.shared.dismissKeyboard()
                            Task {
                                await viewModel.sendTimeRequest()
                            }
                        })
                        {
                            if viewModel.isSendingInvite {
                                ProgressView()
                            } else {
                                Text("Request Time")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isSendingTimeRequest ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(viewModel.isSendingTimeRequest)
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
