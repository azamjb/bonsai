import SwiftUI

struct SettingsView: View {
    
    let smsApi = SMSApi()
    let accountApi = AccountApi()
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    @ObservedObject var editModel: ProfileCreationViewModel = ProfileCreationViewModel()
    private let removePartnerMessage = "Are you sure you want to delete your account? All data will be lost including your manual override tokens"
    @State private var showRemoveConfirmation = false
    @State private var shouldNavigateToLandingPage = false
    @StateObject var screenTime = ScreenTimeService()
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Settings")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    .padding(.top, 15)
                    .padding(.bottom, 45)
                
                NavigationLink(destination: FeedbackFormView()) {
                    VStack(alignment: .leading) {
                        Text("Feedback Form")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 55)
                }
               
                NavigationLink(destination: PrivacyPolicyView()) {
                    VStack(alignment: .leading) {
                        Text("Privacy Policy")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 55)
                }
                
                NavigationLink(destination: TermsAndConditionsView()) {
                    VStack(alignment: .leading) {
                        Text("Terms and Conditions")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 55)
                }
                
                NavigationLink(destination: FreqAskedQuestionsView()) {
                    VStack(alignment: .leading) {
                        Text("Frequently asked Questions")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 55)
                }
                
                NavigationLink(destination: ProfileEditView(viewModel: viewModel)) {
                    VStack(alignment: .leading) {
                        Text("Edit my Account")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 55)
                }
                
                VStack(alignment: .leading) {
                    Button(action: {
                        showRemoveConfirmation = true
                    }) {
                        Text("Delete my Account")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .alert(removePartnerMessage, isPresented: $showRemoveConfirmation) {
                        Button("Delete", role: .destructive) {
                            Task {
                                await deleteUser()
                            }
                        }
                        Button("Cancel", role: .cancel) { }
                    }
                }
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                
                .padding(.bottom, 55)

                NavigationLink(destination: RootView(), isActive: $shouldNavigateToLandingPage) {
                    EmptyView()
                }
            }
            .customBackToolbar()
            .padding(.horizontal, 70)
            .onAppear {
                viewModel.fetchUserProfile()
            }
        }
    }

    private func deleteUser() async {
        do {
            let SMSInvite = SMSInvite(
                number: viewModel.accountabilityPartner.phoneNumber ?? "",
                username: viewModel.userProfile.name ?? "",
                accountabilityPartnerName: viewModel.accountabilityPartner.name ?? "",
                code: ""
            )
           
            let idString = UserDefaults.standard.string(forKey: ProfileKey.id.rawValue)
            let deleteUserRequest = DeleteUser(id: idString ?? "")

            try await smsApi.removalNotif(request: SMSInvite)
            try await accountApi.deleteUser(request: deleteUserRequest)

            await MainActor.run {
                UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                shouldNavigateToLandingPage = true
            }

            UserDefaults.standard.set(false, forKey: "isProfileCreated")
        } catch {
            print("Failed to delete user: \(error)")
        }
    }
}

#Preview {
    SettingsView()
}
