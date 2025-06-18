//
//  FeedbackFormView.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-03-27.
//

import SwiftUI

struct FeedbackRequest : Encodable {
    let Email, Message, Subject: String
}

struct FeedbackResponse : Decodable {
    let Id: String
}

struct FeedbackFormView: View {
    
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    
    @State var message: String = ""
    @State var email: String = ""
    @State private var selectedOption = ""
    @State private var showPopup = false
    
    let api = AccountApi()
    let options = ["Reporting a Bug", "General Feedback", "Suggestions", "Questions"]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    Text("Feedback Form")
                        .font(.system(size: 25))
                        .padding(.top, 15)
                        .padding(.bottom, 35)
                    
                    VStack {
                        Text("Thank you for exploring Bonsai!")
                            .padding(.bottom, 15)
                            .font(.system(size: 14))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("We are constantly working on growing and improving the app, and would love to hear your feedback. ")
                            .padding(.bottom, 15)
                            .font(.system(size: 14))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Whether it's a suggestion, complaint, bug, or general feedback, we highly value our users' thoughts and thank you for your time!")
                            .font(.system(size: 14))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    VStack(alignment: .leading) {
                        CustomDropdownView(selectedOption: $selectedOption)
                            .padding(.top, 30)
                            .padding(.bottom, 20)
                        
                        TextField("email...", text: $email)
                            .font(.system(size: 13))
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .frame(width: 320)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        
                        TextField("message...", text: $message)
                            .modifier(CustomTextFieldStyle3(placeholder: ""))
                    }
                    
                    VStack {
                        BonsaiButtonSmall(buttonText: "Send", onClick: {
                            let feedback = FeedbackRequest(Email: email, Message: message, Subject: selectedOption)
                            Task {
                                do {
                                    try await api.sendFeedback(request: feedback)
                                    
                                    withAnimation {
                                        showPopup = true
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                        withAnimation {
                                            showPopup = false
                                        }
                                    }
                                    
                                    email = ""
                                    message = ""
                                    selectedOption = ""
                                } catch {
                                    print("Error sending feedback: \(error)")
                                }
                            }
                        })
                        
                    }
                    .padding(.bottom, 30)
                    .padding(.top, 30)
                }
                .padding(.horizontal, 40)
            }
            
            if showPopup {
                VStack {
                    Text("Feedback sent!")
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.black.opacity(0.85))
                        .cornerRadius(12)
                        .transition(.opacity)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.clear)
                .animation(.easeInOut, value: showPopup)
            }

        }
        .gesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
        .customBackToolbar()
    }
}

// MARK: - Dropdown Component with Binding
struct CustomDropdownView: View {
    @Binding var selectedOption: String
    @State private var isExpanded = false
    
    let options = ["Reporting a Bug", "General Feedback", "Suggestions", "Questions"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(selectedOption.isEmpty ? "category" : selectedOption)
                        .foregroundColor(selectedOption.isEmpty ? .gray : .black)
                        .font(.system(size: 13))
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .frame(width: 170)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            selectedOption = option
                            isExpanded = false
                        }) {
                            Text(option)
                                .foregroundColor(.black)
                                .font(.system(size: 13))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(Color.white)
                    }
                }
                .background(Color.gray.opacity(0.15))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
            }
        }
        .animation(.easeInOut, value: isExpanded)
    }
}

// MARK: - Custom TextField Modifier
struct CustomTextFieldStyle3: ViewModifier {
    let placeholder: String
    
    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(placeholder)
                .foregroundColor(.secondary)
                .font(.system(size: 13))
            
            content
                .font(.system(size: 13))
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                .frame(height: 120)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Preview
#Preview {
    FeedbackFormView()
}
