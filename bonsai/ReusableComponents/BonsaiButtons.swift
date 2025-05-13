//
//  BonsaiButton.swift
//  bonsai
//
//  Created by Brayden O on 2025-04-18.
//

import SwiftUICore
import SwiftUI

public struct BonsaiButtonRegular: View {
    var buttonText: String
    var onClick: () -> Void
    
    public var body: some View {
        Button(action: {
            onClick()
        }) {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 299, height: 51)
                .cornerRadius(30)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.primary, lineWidth: 1)
                )
                .overlay(
                    Text(buttonText)
                        .foregroundColor(.primary)
                )
        }
    }
}

public struct BonsaiButtonSmall: View {
    var buttonText: String
    var onClick: () -> Void
    
    public var body: some View {
        Button(action: {
            onClick()
        }) {
            Text(buttonText)
                .font(.system(size: 15))
                .foregroundColor(.primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.primary, lineWidth: 1)
                )
        }
    }
}

public struct BonsaiNavLinkSmall<Destination: View>: View {
    var buttonText: String
    var destination: Destination
    
    public init(buttonText: String, destination: Destination) {
        self.buttonText = buttonText
        self.destination = destination
    }
    
    public var body: some View {
        NavigationLink(destination: destination) {
            Text(buttonText)
                .font(.system(size: 16))
                .foregroundColor(.primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.primary, lineWidth: 1)
                )
        }
    }
}
