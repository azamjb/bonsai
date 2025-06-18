//
//  BonsaiButton.swift
//  bonsai
//
//  Created by Brayden O on 2025-04-18.
//

import SwiftUICore
import SwiftUI

public struct BonsaiButtonRegular: View {
    var contrastedColorTheme: Bool = false
    var buttonText: String
    var onClick: () -> Void
    
    @State private var isPressed = false
    
    public var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
                onClick()
            }
        }) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 300, height: 50)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(contrastedColorTheme ? Color(.systemBackground) : Color.primary, lineWidth: 1)
                )
                .overlay(
                    Text(buttonText)
                        .foregroundColor(contrastedColorTheme ? Color(.systemBackground) : Color.primary)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}


public struct BonsaiButtonSmall: View {
    var buttonText: String
    var onClick: () -> Void
    
    @State private var isPressed = false
    
    public var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
                onClick()
            }
        }) {
            Text(buttonText)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .padding(.vertical, 10)
                .frame(minWidth: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.primary, lineWidth: 1)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
    }
}


public struct BonsaiNavLinkSmall<Destination: View>: View {
    var buttonText: String
    var destination: Destination
    
    @State private var isPressed = false
    @State private var isPresented = false
    
    public init(buttonText: String, destination: Destination) {
        self.buttonText = buttonText
        self.destination = destination
    }
    
    public var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
                isPresented = true
            }
        }) {
            Text(buttonText)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .padding(.vertical, 10)
                .frame(minWidth: 300)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.primary, lineWidth: 1)
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .navigationDestination(isPresented: $isPresented) {
            destination
        }
    }
}


