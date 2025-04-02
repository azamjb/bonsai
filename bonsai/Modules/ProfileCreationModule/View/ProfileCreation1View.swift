import SwiftUI

struct ProfileCreation1View: View {
    @Environment(\.presentationMode) var presentationMode
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
                    
                    Image("BonsaiLogo_grey")
                        .padding(.bottom, 25)
                                        
                    VStack(spacing: 16) {
                        Group {
                            HStack(alignment: .center) {
                                TextField("", text: $name)
                                    .modifier(CustomTextFieldStyle(placeholder: "Enter name:"))
                                    .frame(height: 40)
                                    .focused($isFieldFocused)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke( Color.clear, lineWidth: 2)
                                    )
                                    .offset(x: isShaking ? -10 : 0) // Shake effect
                                    .animation(isShaking ? .default.repeatCount(3, autoreverses: true) : .default, value: isShaking)

                                let forwardButton = Image(systemName: "chevron.right")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .padding(12)
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
                                    }
                                }) {
                                    forwardButton
                                }
                                .padding(.top, 24)
                            }
                            .frame(height: 50)
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            .onTapGesture {
                hideKeyboard()
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16))
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $isNavigating) {
                ProfileCreation2View(name: name)
            }
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
                .padding(.vertical, 8)
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
