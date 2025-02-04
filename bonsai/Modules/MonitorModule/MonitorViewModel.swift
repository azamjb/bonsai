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
    @Published var monitoringStarted: Bool = false
    @Published var timeLimitMinutesString: String = "1"
    @Published var enteredPin: String = ""
    @Published var pinError: String? = nil
    @Published var purchaseSuccessful = false

    // Product ID for the in-app purchase
    private let productID = "com.azam.bonsai.screentimemanualoverride"
    private var product: Product?
    
    // TODO
    public func onExtendPressed(appToken: ApplicationToken?, categoryToken: ActivityCategoryToken?, webToken: WebDomainToken?) {
        if(appToken != nil) {
            
        } else if (categoryToken != nil) {
            
        } else if (webToken != nil) {
            
        }
    }
}
 
