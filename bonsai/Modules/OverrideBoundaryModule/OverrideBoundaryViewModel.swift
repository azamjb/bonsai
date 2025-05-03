//
//  OverrideBoundaryViewModel.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-05-03.
//

import Combine
import Foundation

class OverrideBoundaryViewModel: ObservableObject {
    @Published var tokenTransactions: [TokenTransaction] = []
    private let tokenService: TokenServiceProtocol
    
    init() {
        let tokenStorage = TokenStorageService(database: LocalDatabase.shared.databaseWriter)
        self.tokenService = TokenService(storage: tokenStorage)
    }
    
    func fetchTokenTransactions() async {
        
    }
}
