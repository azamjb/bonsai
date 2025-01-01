//
//  NavGuardService.swift
//  bonsai
//
//  Created by Brayden O on 2024-12-31.
//

import Foundation
import UIKit
import SwiftUI

class NavGuardService: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    func refreshIsLoggedIn() {
        let bearer = UserDefaults.standard.string(forKey: LocalStorageKeys.bearer)
        let userId = UserDefaults.standard.string(forKey: LocalStorageKeys.userId)
        
        isLoggedIn = bearer != nil && userId != nil
    }
    
    func logout() {
        UserDefaults.standard.set(nil, forKey: LocalStorageKeys.bearer)
        UserDefaults.standard.set(nil, forKey: LocalStorageKeys.userId)
    }
}
