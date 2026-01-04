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
    @FocusState private var isTextFieldFocused: Bool
    @State private var internalCode: String = ""

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Hidden TextField that captures all input and autofill
                TextField("", text: $internalCode)
                    .textContentType(.oneTimeCode)
                    .keyboardType(.numberPad)
                    .autocorrectionDisabled(true)
                    .focused($isTextFieldFocused)
                    .frame(width: 0, height: 0)
                    .opacity(0)
                    .onChange(of: internalCode) { _, newValue in
                        handleCodeChange(newValue)
                    }

                // Visual representation of 6 digit boxes
                HStack(spacing: 8) {
                    ForEach(0..<6, id: \.self) { index in
                        DigitBox(
                            digit: digitAt(index),
                            isActive: isTextFieldFocused && code.count == index
                        )
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 10)
                .contentShape(Rectangle())
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isTextFieldFocused = true
            }

            // Paste button
            Button(action: pasteFromClipboard) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 14))
                    Text("Paste Code")
                        .font(.system(size: 14))
                }
                .foregroundColor(.blue)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 1)
                )
            }
        }
        .onAppear {
            internalCode = code
        }
        .onChange(of: code) { _, newValue in
            // Update internal code if code binding changes externally
            if newValue != internalCode {
                internalCode = newValue
            }
        }
    }

    private func digitAt(_ index: Int) -> String {
        let codeArray = Array(code)
        return index < codeArray.count ? String(codeArray[index]) : ""
    }

    private func handleCodeChange(_ newValue: String) {
        // Extract digits only
        let filtered = newValue.filter { $0.isNumber }
        let limited = String(filtered.prefix(6))

        // Update the binding
        code = limited

        // Keep internal code in sync
        if internalCode != limited {
            internalCode = limited
        }

        // If we got exactly 6 digits, dismiss keyboard
        if limited.count == 6 {
            isTextFieldFocused = false
        }
    }

    private func pasteFromClipboard() {
        if let clipboardString = UIPasteboard.general.string {
            let digits = clipboardString.filter { $0.isNumber }
            let sixDigits = String(digits.prefix(6))
            internalCode = sixDigits
            code = sixDigits
        }
    }
}

// Visual box for each digit
struct DigitBox: View {
    let digit: String
    let isActive: Bool

    var body: some View {
        ZStack {
            // Background with border
            RoundedRectangle(cornerRadius: 8)
                .stroke(isActive ? Color.secondary : Color.clear, lineWidth: 2)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.clear)
                )

            // Digit text
            Text(digit)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.primary)

            // Bottom underline
            VStack {
                Spacer()
                Rectangle()
                    .fill(Color.primary)
                    .frame(height: 2)
            }
            .padding(.horizontal, 4)
        }
        .frame(width: 45, height: 55)
    }
}

