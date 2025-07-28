//
//  ContentContainer.swift
//  bonsai
//
//  Created by Brayden O on 2025-07-27.
//

import SwiftUICore
import UIKit

struct ContentContainer<Content: View>: View {
    let content: () -> Content
    var isVisible: Bool = true
    var backgroundColor: Color = Color(uiColor: UIColor(named: "contentContainerBg")!)
    var cornerRadius: CGFloat = 12
    var padding: EdgeInsets = EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16)
    var outerPadding: EdgeInsets = EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8)
    var shadowRadius: CGFloat = 12
    var shadowColor: Color = Color(uiColor: UIColor(named: "contentContainerShadow")!)
    var borderColor: Color = Color(uiColor: UIColor(named: "contentContainerBorder")!)
    var borderWidth: CGFloat = 1
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity)
            .background(isVisible ? backgroundColor : Color.clear)
            .cornerRadius(isVisible ? cornerRadius : 0)
            .overlay(
                RoundedRectangle(cornerRadius: isVisible ? cornerRadius : 0)
                    .stroke(isVisible ? borderColor : Color.clear, lineWidth: isVisible ? borderWidth : 0)
                    .opacity(0.5)
            )
            //.shadow(color: isVisible ? shadowColor : Color.clear, radius: isVisible ? shadowRadius : 0, x: 0, y: 1)
            .padding(outerPadding)
    }
}

extension ContentContainer {
    func isVisible(_ isVisible: Bool) -> ContentContainer {
        var container = self
        container.isVisible = isVisible
        return container
    }
    
    func backgroundColor(_ color: Color) -> ContentContainer {
        var container = self
        container.backgroundColor = color
        return container
    }
    
    func cornerRadius(_ radius: CGFloat) -> ContentContainer {
        var container = self
        container.cornerRadius = radius
        return container
    }
    
    func padding(_ insets: EdgeInsets) -> ContentContainer {
        var container = self
        container.padding = insets
        return container
    }
    
    func padding(_ value: CGFloat) -> ContentContainer {
        var container = self
        container.padding = EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
        return container
    }
    
    func outerPadding(_ insets: EdgeInsets) -> ContentContainer {
        var container = self
        container.outerPadding = insets
        return container
    }
    
    func outerPadding(_ value: CGFloat) -> ContentContainer {
        var container = self
        container.outerPadding = EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
        return container
    }
    
    func outerPadding(_ edges: Edge.Set, _ value: CGFloat) -> ContentContainer {
        var container = self
        var currentPadding = container.outerPadding
        
        if edges.contains(.top) { currentPadding.top = value }
        if edges.contains(.leading) { currentPadding.leading = value }
        if edges.contains(.bottom) { currentPadding.bottom = value }
        if edges.contains(.trailing) { currentPadding.trailing = value }
        
        container.outerPadding = currentPadding
        return container
    }
    
    func shadow(color: Color = Color.black.opacity(0.1), radius: CGFloat = 2) -> ContentContainer {
        var container = self
        container.shadowColor = color
        container.shadowRadius = radius
        return container
    }
    
    func border(color: Color, width: CGFloat = 1) -> ContentContainer {
        var container = self
        container.borderColor = color
        container.borderWidth = width
        return container
    }
    
    func noBorder() -> ContentContainer {
        var container = self
        container.borderWidth = 0
        return container
    }
}
