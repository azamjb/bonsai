//
//  EducateViewModel.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-12.
//

import Combine
import Foundation

class EducateViewModel: ObservableObject {
    @Published var content: [EducationContent] = []
    
    func loadDefaultContent() {
        content = [
            EducationContent(title: "How to Stay Focused", description: "A video about staying focused."),
            EducationContent(title: "Daily Motivation", description: "A motivational article.")
        ]
    }
    
}

struct EducationContent: Identifiable {
    let id = UUID()
    let title: String
    let description: String
}
