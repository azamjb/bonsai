import SwiftUI

struct ProfileCreation1View: View {

    @StateObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()
    @State private var name: String = ""
    @FocusState private var isFieldFocused: Bool
    
    @State private var isShaking = false 
    @State private var isNavigating = false
    let accountApi = AccountApi()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()
                    
                                        
                    VStack(spacing: 8) {
                        
                        Text("Account Setup")
                            .padding(.horizontal, 10)
                            .font(.system(size: 29))
                            .frame(alignment: .leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fontWeight(.bold)
                            
                        Group {
                            HStack(alignment: .center) {
                                BonsaiTextField(binding: $name, placeholder: "Enter Name")

                                let forwardButton = Image(systemName: "chevron.right")
                                    .font(.system(size: 19))
                                    .foregroundColor(.white)
                                    .padding(15)
                                    .background(Color.primary)
                                    .clipShape(Circle())

                                Button(action: {
                                    if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        isShaking = true
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            isShaking = false
                                        }
                                    } else {
                                        // Navigate if valid
                                        Task {
                                            try await AccountApi().connectionPrompt()
                                        }
                                        
                                        isNavigating = true
                                        Task {
                                            await viewModel.saveProfileFields(
                                                name: name,
                                                phoneNumber: "0",
                                                hobbies: nil,
                                                termsAccepted: nil
                                            )
                                        }
                                    }
                                }) {
                                    forwardButton
                                }
                            }
                            .frame(height: 50)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    Spacer()
                    
                    NavigationLink(
                        destination: DailyScreenTimeView(name: name, phoneNumber:"0"),
                        isActive: $isNavigating
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationBarBackButtonHidden(true)
        }
        .preferredColorScheme(.light)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

// Custom Modifier for Input Fields
struct CustomTextFieldStyle: ViewModifier {
    let placeholder: String
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(placeholder)
                .foregroundColor(.primary)
                .font(.body)
                .padding(.leading, 10)
            content
                .padding(.vertical, 13)
                .padding(.horizontal, 12)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(20)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    ProfileCreation1View()
}
