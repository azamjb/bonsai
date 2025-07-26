import SwiftUI

struct ProfileCreation2View: View {

    @StateObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()
    @State var name: String
    @State private var rawPhoneNumber: String = ""
    @FocusState var isFieldFocused: Bool
    @State private var isShaking = false
    @State private var isNavigating = false

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

                        HStack(alignment: .center) {
                            BonsaiPhoneNumberField(binding: $rawPhoneNumber, placeholder: "Enter Phone Number")
                            
                            let forwardButton = Image(systemName: "chevron.right")
                                .font(.system(size: 19))
                                .foregroundColor(.white)
                                .padding(15)
                                .background(Color.primary)
                                .clipShape(Circle())

                            Button(action: {
                                if rawPhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    isShaking = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        isShaking = false
                                    }
                                } else {
                                    //let formatted = formatPhoneNumber(rawPhoneNumber)
                                    isNavigating = true
                                    Task {
                                        await viewModel.saveProfileFields(
                                            name: name,
                                            phoneNumber: rawPhoneNumber,
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
                    .padding(.horizontal, 16)

                    Spacer()
                    Spacer()

                    NavigationLink(
                        destination: DailyScreenTimeView(name: name, phoneNumber: formatPhoneNumber(rawPhoneNumber)),
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
                isFieldFocused = false
            }
        }
        .preferredColorScheme(.light)
        .navigationBarHidden(true)
    }

    private func formatPhoneNumber(_ number: String) -> String {
        let digits = number.filter { $0.isNumber }.prefix(10)

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
