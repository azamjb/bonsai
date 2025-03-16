import SwiftUI

struct BoundaryExtensionRequestView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel = AccountabilityPartnerViewModel()
    
    @State private var requestNote: String = ""
    @State private var pin: String = ""
    @FocusState private var isFieldFocused: Bool
    @AppStorage("isProfileCreated") private var isProfileCreated = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading) {
                        Spacer()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Request")
                                .font(.title2)
                            
                            Text("Boundary Extension")
                                .font(.title2)
                        }
                        .padding(.bottom, 40)
                        
                        VStack {
                            Text("SELECT APPS")
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 6)
                            
                            Text("You haven't hit any boundaries today.")
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(spacing: 16) {
                            TextField("Add a note...", text: $requestNote)
                                .modifier(CustomTextFieldStyle2(placeholder: ""))
                                .frame(minHeight: 50)
                                .focused($isFieldFocused)
                        }
                        .padding(.bottom, 30)
                        
                        Button(action: {
                            Task {
                                await viewModel.sendTimeRequest()
                            }
                        }) {
                            Text("send code to partner")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                                .padding(.vertical, 15)
                                .padding(.horizontal, 80)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                        .padding(.bottom, 30)
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color.black)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                        
                        VStack {
                            Text("SENT REQUEST CODES")
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 6)
                            
                            Text("You haven't sent your partner any codes yet.")
                                .font(.system(size: 15))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(.gray)
                        }
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color.black)
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
                                await viewModel.validateVerificationCode()
                            }
                        }) {
                            Text("enter code")
                                .font(.system(size: 15))
                                .foregroundColor(.black)
                                .padding(.vertical, 15)
                                .padding(.horizontal, 80)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                        .padding(.bottom, 20)
                    }
                    .padding(.horizontal, 40)
                }
                .navigationBarBackButtonHidden(true)
                .onTapGesture {
                    hideKeyboard()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar) // ✅ Fully removes the top bar background
            .navigationBarTitleDisplayMode(.inline) // ✅ Prevents extra spacing
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct PinEntryView: View {
    @Binding var pin: String
    @FocusState private var isPinFocused: Bool  // ✅ Focus state to handle keyboard

    private let pinLength = 6
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<pinLength, id: \.self) { index in
                ZStack {
                    Text(pin.count > index ? String(pin[pin.index(pin.startIndex, offsetBy: index)]) : "")
                        .font(.title)
                        .foregroundColor(.black)
                    
                    Rectangle()
                        .frame(width: 30, height: 2)
                        .foregroundColor(.black)
                        .offset(y: 20)
                }
            }
        }
        .contentShape(Rectangle()) // ✅ Ensures the entire view is tappable
        .onTapGesture {
            isPinFocused = true // ✅ Focus on text field when tapped
        }
        .background(
            TextField("", text: $pin)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(width: 0, height: 0) // ✅ Hide actual text field
                .opacity(0)
                .focused($isPinFocused) // ✅ Bind focus state
        )
    }
}

struct CustomTextFieldStyle2: ViewModifier {
    let placeholder: String
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(placeholder)
                .foregroundColor(.gray)
                .font(.system(size: 15))
            
            content
                .padding()
                .frame(height: 120) // Keep it a large text box
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.black)
        }
    }
}

#Preview {
    BoundaryExtensionRequestView()
}
