//
//  BoundaryCreatorViewModel.swift
//  bonsai
//
//  Created by Brayden O on 2025-03-09.
//

import Combine
import Foundation
import DeviceActivity
import FamilyControls
import ManagedSettings
import StoreKit

@MainActor
class BoundaryDetailsViewModel: ObservableObject {
    // For testing conditionals in view. Can't print stuff directly.
    public func printHere() {
        print("here")
    }
}
