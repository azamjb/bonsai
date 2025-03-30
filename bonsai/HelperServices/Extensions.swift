//
//  Extensions.swift
//  bonsai
//
//  Created by Brayden O on 2025-03-28.
//

extension String {
    func shorted(to symbols: Int) -> String {
        guard self.count > symbols else {
            return self
        }
        return self.prefix(symbols) + " ..."
    }
}
