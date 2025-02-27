//
//  MonitorViewModel.swift
//  bonsai
//
//  Created by Brayden O on 2025-01-01.
//

import Combine
import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings
import StoreKit

@MainActor
class MonitorViewModel: ObservableObject {
    // For testing conditionals in view. Can't print stuff directly.
    public func printHere() {
        print("here")
    }
}
 
