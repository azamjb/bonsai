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
        let bearer = UserDefaults.standard.string(forKey: BEARER_STRING)
        let userId = UserDefaults.standard.string(forKey: USER_ID_STRING)
        
        isLoggedIn = bearer != nil && userId != nil
    }
    
    func logout() {
        UserDefaults.standard.set(nil, forKey: BEARER_STRING)
        UserDefaults.standard.set(nil, forKey: USER_ID_STRING)
    }
}
