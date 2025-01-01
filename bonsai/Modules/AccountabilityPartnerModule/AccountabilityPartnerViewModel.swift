//
//  AccountabilityPartnerViewModel.swift
//  bonsai
//
//  Created by Brayden O on 2025-01-01.
//

import Foundation
import FamilyControls

public class ScreenTimeSelectAppsModel: ObservableObject {
    static let shared = ScreenTimeSelectAppsModel()
    
    @Published var activitySelection = FamilyActivitySelection()
    
    private let userDefaultsKey = "SelectedActivity"
    private let appGroupID = "group.com.bonsai" // Replace with your actual App Group ID
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    public func saveSelection() {
        let encoder = JSONEncoder()
        do {
            let encoded = try encoder.encode(activitySelection)
            sharedDefaults?.set(encoded, forKey: userDefaultsKey)
            print("Selection successfully saved: \(activitySelection)")
        } catch {
            print("Failed to encode selection: \(error)")
        }
    }

    public func loadSelection() -> FamilyActivitySelection? {
        let decoder = JSONDecoder()
        if let data = sharedDefaults?.data(forKey: userDefaultsKey) {
            do {
                let selection = try decoder.decode(FamilyActivitySelection.self, from: data)
                print("Selection successfully loaded: \(selection)")
                return selection
            } catch {
                print("Failed to decode selection: \(error)")
            }
        } else {
            print("No data found in shared UserDefaults for key: \(userDefaultsKey)")
        }
        return nil
    }
}
