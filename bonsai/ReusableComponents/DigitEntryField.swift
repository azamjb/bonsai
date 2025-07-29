//
//  DigitEntryField.swift
//  bonsai
//
//  Created by Brayden O on 2025-07-28.
//

import SwiftUI
import Combine

struct SixDigitCodeField: View {
    @Binding var code: String
    @FocusState private var focusedField: Int?
    @State private var digits: [String] = Array(repeating: "", count: 6)
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<6, id: \.self) { index in
                DigitField(
                    text: $digits[index],
                    onChanged: { newValue in
                        handleDigitChange(at: index, newValue: newValue)
                    },
                    onBackspace: {
                        handleBackspace(at: index)
                    },
                    onTap: {
                        handleFieldTap()
                    }
                )
                .focused($focusedField, equals: index)
                .frame(width: 45, height: 55)
                .overlay(
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color.primary)
                            .frame(height: 2)
                    }
                )
            }
        }
        .onAppear {
            // Initialize digits from binding
            updateDigitsFromCode()
        }
        .onChange(of: code) { _, _ in
            // Update digits if code changes externally
            updateDigitsFromCode()
        }
    }
    
    private func handleDigitChange(at index: Int, newValue: String) {
        // Allow only digits
        let filtered = newValue.filter { $0.isNumber }
        
        if filtered.count > 1 {
            // If pasted multiple digits, distribute them
            let pastedDigits = Array(filtered.prefix(6 - index))
            for (offset, digit) in pastedDigits.enumerated() {
                if index + offset < 6 {
                    digits[index + offset] = String(digit)
                }
            }
            // Focus on the next empty field or last field
            let nextEmptyIndex = digits.firstIndex(where: { $0.isEmpty }) ?? 5
            focusedField = min(nextEmptyIndex, 5)
        } else if filtered.count == 1 {
            // Single digit input
            digits[index] = String(filtered.prefix(1))
            
            // Auto-advance focus
            if index < 5 {
                focusedField = index + 1
            }
        } else if newValue.isEmpty && digits[index].isEmpty {
            // Handle backspace on empty field - go to previous
            if index > 0 {
                focusedField = index - 1
            }
        } else {
            // Clear the field
            digits[index] = ""
        }
        
        // Update the binding
        updateCodeBinding()
    }
    
    private func handleBackspace(at index: Int) {
        if digits[index].isEmpty && index > 0 {
            // If current field is empty, move to previous field and clear it
            focusedField = index - 1
            digits[index - 1] = ""
        } else {
            // Clear current field
            digits[index] = ""
        }
        updateCodeBinding()
    }
    
    private func handleFieldTap() {
        // Find the first empty field
        if let firstEmptyIndex = digits.firstIndex(where: { $0.isEmpty }) {
            focusedField = firstEmptyIndex
        } else {
            // If all fields are filled, focus on the last field
            focusedField = 5
        }
    }
    
    private func updateCodeBinding() {
        code = digits.joined()
    }
    
    private func updateDigitsFromCode() {
        let codeArray = Array(code.prefix(6))
        for i in 0..<6 {
            digits[i] = i < codeArray.count ? String(codeArray[i]) : ""
        }
    }
}

// Custom UITextField to detect backspace
struct DigitField: UIViewRepresentable {
    @Binding var text: String
    let onChanged: (String) -> Void
    let onBackspace: () -> Void
    let onTap: () -> Void

    func makeUIView(context: Context) -> UITextField {
        let textField = BackspaceTextField()
        textField.delegate = context.coordinator
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.font = .systemFont(ofSize: 24, weight: .semibold)
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.tintColor = .tintColor
        
        // Set up backspace detection
        textField.onBackspace = { [weak textField] in
            if textField?.text?.isEmpty ?? true {
                onBackspace()
            }
        }
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        textField.addGestureRecognizer(tapGesture)
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        
        // Update border color
        if text.isEmpty {
            uiView.layer.borderColor = UIColor.systemGray4.cgColor
        } else {
            uiView.layer.borderColor = UIColor.tintColor.cgColor
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
            let parent: DigitField
            
            init(_ parent: DigitField) {
                self.parent = parent
            }
            
            @objc func handleTap() {
                parent.onTap()
            }
            
            func textFieldDidBeginEditing(_ textField: UITextField) {
                parent.onTap()
            }
            
            func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
                let currentText = textField.text ?? ""
                let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
                
                // Allow backspace
                if string.isEmpty && range.length == 1 {
                    parent.onChanged("")
                    return true
                }
                
                // Only allow digits
                if !string.isEmpty && !string.allSatisfy({ $0.isNumber }) {
                    return false
                }
                
                parent.onChanged(newText)
                return false
            }
        }}

// Custom TextField subclass to detect backspace
class BackspaceTextField: UITextField {
    var onBackspace: (() -> Void)?
    
    override func deleteBackward() {
        if text?.isEmpty ?? true {
            onBackspace?()
        }
        super.deleteBackward()
    }
}
