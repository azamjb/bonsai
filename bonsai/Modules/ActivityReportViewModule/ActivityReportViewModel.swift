//
//  ActivityReportViewModel.swift
//  bonsai
//
//  Created by Brayden O on 2025-01-01.
//

import Combine
import Foundation
@MainActor class ActivityReportViewModel: ObservableObject {
    
    
    var currentMonth: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM"
            return dateFormatter.string(from: Date())
        }
    
}
