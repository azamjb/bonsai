//
//  PinEntryField.swift
//  bonsai
//
//  Created by Brayden O on 2025-02-02.
//
import SwiftUI

struct PINEntryField: View {
    @Binding var pin: String
    @FocusState private var isPinEntryFocused: Bool
    let maxDigits: Int = 6
    var onComplete: (() -> Void)?  // Callback when input is finished
    
    var body: some View {
        VStack {
            HStack(spacing: 12) {
                ForEach(0..<maxDigits, id: \.self) { index in
                    PINDigitField(index: index, pin: $pin)
                }
            }
            .padding()
            .onTapGesture {
                isPinEntryFocused = true
            }
            
            TextField("", text: $pin)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($isPinEntryFocused)
                .opacity(0)
                .onChange(of: pin) { _, newValue in
                    pin = String(newValue.prefix(maxDigits))
                    
                    if pin.count == maxDigits {
                        isPinEntryFocused = false
                        onComplete?()
                    }
                }
        }
    }
}

struct PINDigitField: View {
    let index: Int
    @Binding var pin: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 1)
                .frame(width: 40, height: 50)
            
            if index < pin.count {
                Text(String(pin[pin.index(pin.startIndex, offsetBy: index)]))
                    .font(.title2)
                    .bold()
            }
        }
    }
}
