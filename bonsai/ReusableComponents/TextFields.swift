//
//  TextFields.swift
//  bonsai
//
//  Created by Brayden O on 2025-06-14.
//

import SwiftUI
import iPhoneNumberField

private struct BaseTextField : View {
    var binding: Binding<String>
    var existingValue: String?
    var placeholder: String? // Shows within the text field
    var title: String? // Shows above the field
    var showEditIndicator: Bool = false
    var input: AnyView
    var onClear: (() -> Void)?
    
    var body : some View {
        VStack(alignment: .leading) {
            if title != nil {
                HStack {
                    Text(title!)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    if showEditIndicator && binding.wrappedValue != existingValue {
                        Image(systemName: "pencil.circle.fill")
                            .foregroundColor(.blue)
                            .font(.system(size: 12))
                    }
                }
            }
            
            HStack {
                input
                
                Button(action: {
                    binding.wrappedValue = ""
                    
                    if onClear != nil { onClear!() }
                }) {
                    Text("x")
                        .foregroundStyle(Color(uiColor: UIColor(named: "textFieldX")!))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.secondary.opacity(0.15))
            .clipShape(.buttonBorder)
        }
    }
}

public struct BonsaiTextField: View {
    var binding: Binding<String>
    var existingValue: String?
    var placeholder: String? // Shows within the text field
    var title: String? // Shows above the field
    var showEditIndicator: Bool = false
    var onChange: (() -> Void)?
    
    @FocusState private var isFocused: Bool
    
    public var body : some View {
        BaseTextField(
            binding: binding,
            existingValue: existingValue,
            title: title,
            showEditIndicator: showEditIndicator,
            input: AnyView(
                TextField(placeholder ?? "", text: binding) {
                    UIApplication.shared.endEditing()
                }
                .textFieldStyle(.plain)
                .focused($isFocused)
                .onChange(of: binding.wrappedValue) { _, value in
                    if onChange != nil { onChange!() }
                }
            )
        ) { isFocused = true }
    }
}

public struct BonsaiPhoneNumberField: View {
    var binding: Binding<String>
    var existingValue: String?
    var placeholder: String? // Shows within the text field
    var title: String? // Shows above the field
    var showEditIndicator: Bool = false
    var onChange: (() -> Void)?
    
    @FocusState private var isFocused: Bool

    public var body: some View {
        BaseTextField(
            binding: binding,
            existingValue: existingValue,
            title: title,
            showEditIndicator: showEditIndicator,
            input: AnyView(
                iPhoneNumberField(placeholder ?? "(000) 000-0000", text: binding)
                    .flagHidden(false)
                    .flagSelectable(true)
                    .onEdit() { value in
                        // Based on the docs, .formatted(false) should be doing this, but for some reason it force clears a formatted number (bug with library). This is the workaround for getting the full number.
                        if let phoneNumber = value.phoneNumber {
                            binding.wrappedValue = "+" + String(phoneNumber.countryCode) + String(phoneNumber.nationalNumber)
                        }
                        
                        if onChange != nil { onChange!() }
                    }
                    .focused($isFocused)
            )
        ) { isFocused = true }
    }
}

// TODO: make this conform to the base text field.
public struct PinEntryView: View {
    @Binding var pin: String
    @FocusState private var isPinFocused: Bool

    private let pinLength = 6

    public var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<pinLength, id: \.self) { index in
                ZStack {
                    Text(pin.count > index ? String(pin[pin.index(pin.startIndex, offsetBy: index)]) : "")
                        .font(.title)
                        .foregroundColor(.primary)

                    Rectangle()
                        .frame(width: 30, height: 2)
                        .foregroundColor(.primary)
                        .offset(y: 20)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isPinFocused = true
        }
        .background(
            TextField("", text: $pin)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .frame(width: 0, height: 0)
                .opacity(0)
                .focused($isPinFocused)
        )
    }
}
