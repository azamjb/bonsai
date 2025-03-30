import SwiftUI

struct ProfileCreation2View: View {
    @Environment(\.presentationMode) var presentationMode 
    @StateObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()
    @State var name: String
    @State var phoneNumber: String = ""
    @FocusState var isFieldFocused: Bool
    @State private var isShaking = false
    @State private var isNavigating = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Logo and Header
                    Spacer()
                    
                    Image("BonsaiLogo_grey")
                        .padding(.bottom, 25)
                                        
                    // Input Fields
                    VStack(spacing: 16) {
                        Group {
                            HStack(alignment: .center) {
                                TextField("", text: $phoneNumber)
                                    .keyboardType(.numberPad)
                                    .modifier(CustomTextFieldStyle(placeholder: "Enter phone number:"))
                                    .frame(height: 40)
                                    .focused($isFieldFocused)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke( Color.clear, lineWidth: 2)
                                    )
                                    .offset(x: isShaking ? -10 : 0) // Shake effect
                                    .animation(isShaking ? .default.repeatCount(3, autoreverses: true) : .default, value: isShaking)
                                    .onChange(of: phoneNumber) { _, newValue in
                                        phoneNumber = formatPhoneNumber(newValue)
                                    }
                                
                                let forwardButton = Image(systemName: "chevron.right")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(Color.black)
                                    .clipShape(Circle())
                                
                                Button(action: {
                                    if phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        isShaking = true
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            isShaking = false
                                        }
                                    } else {
                                        // Navigate if valid
                                        isNavigating = true
                                        
                                        Task {
                                            await viewModel.saveBasicInfo(name: name, phoneNumber: phoneNumber) // save name and phone number
                                        }
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
                isFieldFocused = false
            }
            .navigationBarBackButtonHidden(true) // Hides the default back button
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left") // Custom back arrow icon
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .navigationDestination(isPresented: $isNavigating) {
                DailyScreenTimeView(name: name, phoneNumber: phoneNumber)
            }
        }
        .preferredColorScheme(.light)
        .onTapGesture {
            hideKeyboard()
            isFieldFocused = false
        }
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }
        
        let areaCode = digits.prefix(3)
        let prefix = digits.dropFirst(3).prefix(3)
        let lineNumber = digits.dropFirst(6).prefix(4)
        
        var formatted = ""
        
        if !areaCode.isEmpty {
            formatted += "(\(areaCode)) "
        }
        if !prefix.isEmpty {
            formatted += "\(prefix)-"
        }
        if !lineNumber.isEmpty {
            formatted += "\(lineNumber)"
        }
        
        return formatted
    }
}

#Preview {
    ProfileCreation2View(name: "azam")
}
