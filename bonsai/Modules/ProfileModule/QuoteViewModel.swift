//
//  QuoteViewModel.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-05-07.
//

struct Quote: Codable {
    let quote: String
    let author: String
}

import Foundation

@MainActor
class QuoteViewModel: ObservableObject {
    @Published var quote: Quote?

    init() {
        loadRandomQuote()
    }

    private func loadQuotes() -> [Quote] {
        guard let url = Bundle.main.url(forResource: "motivational_quotes", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let quotes = try? JSONDecoder().decode([Quote].self, from: data) else {
            return []
        }
        return quotes
    }

    func loadRandomQuote() {
        let quotes = loadQuotes()
        self.quote = quotes.randomElement()
    }
}
