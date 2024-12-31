//
//  GlobalFunctions.swift
//  bonsai
//
//  Created by Azam Jawad on 2024-12-30.
//

import Foundation
import UIKit

public func writeHello() {
    print("helooooooooo")
}

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder),
                   to: nil,
                   from: nil,
                   for: nil)
    }
}
