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
    var onChange: ((String) -> Void)?
    
    @FocusState private var isFocused: Bool
    @State private var maxDigits: Int = 10
    @State private var lastCountryCode: UInt64?
    
    public var body: some View {
        BaseTextField(
            binding: binding,
            existingValue: existingValue,
            title: title,
            showEditIndicator: showEditIndicator,
            input: AnyView(
                iPhoneNumberField(placeholder ?? "(000) 000-0000", text: binding)
                    .maximumDigits(maxDigits)
                    .flagHidden(false)
                    .flagSelectable(true)
                    .onEdit() { value in
                        if let phoneNumber = value.phoneNumber {
                            binding.wrappedValue = "+" + String(phoneNumber.countryCode) + String(phoneNumber.nationalNumber)
                            
                            switch phoneNumber.countryCode {
                            case 1: maxDigits = 10 // US/Canada
                            case 44: maxDigits = 11 // UK
                            case 91: maxDigits = 10 // India
                            default: maxDigits = 15 // fallback (E.164 max is 15 digits)
                           }
                        }
                        
                        onChange?(binding.wrappedValue)
                    }
                    .focused($isFocused)
            )
        ) { isFocused = true }
    }
}
