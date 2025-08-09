//
//  PaymentViewModel.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-05-19.
//

import Foundation
import Combine
import StoreKit

@MainActor
class PaymentViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var isPurchasing = false
    
    // MARK: - Private Properties
    private var selectedTokenBundle: PurchaseOption = .one
    private let tokenService: TokenServiceProtocol
    private let profileService: ProfileServiceProtocol
    private let userId: String
    private var updateListenerTask: Task<Void, Error>?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        let tokenStorage = TokenStorageService(database: LocalDatabase.shared.databaseWriter)
        self.tokenService = TokenService(storage: tokenStorage)
        self.profileService = ProfileService()
        userId = profileService.fetchUserProfile().Id ?? "Unknown User"
        
        // Start listening for transactions
        updateListenerTask = listenForTransactions()
        
        // Load products on init
        Task {
            await loadProducts()
            await checkForUnfinishedTransactions()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - StoreKit Product Management
    
    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let productIds = PurchaseOption.allCases.map { $0.productId }
            products = try await Product.products(for: productIds)
            print("Successfully loaded \(products.count) products from StoreKit")
        } catch {
            print("Failed to load products from StoreKit: \(error.localizedDescription)")
            errorMessage = "Unable to load products. Please check your connection and try again."
            showError = true
        }
    }
    
    func product(for option: PurchaseOption) -> Product? {
        products.first { $0.id == option.productId }
    }
    
    // MARK: - Purchase Flow
    func purchaseSelectedTokenBundle(selectedOption: PurchaseOption) async throws -> Bool {
        selectedTokenBundle = selectedOption
        
        guard let product = product(for: selectedOption) else {
            errorMessage = "Product not available. Please try again later."
            showError = true
            throw PaymentError.productNotFound
        }
        
        isPurchasing = true
        defer { isPurchasing = false }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                await processPurchase(
                    transaction: transaction,
                    tokenAmount: selectedOption.amount
                )
                
                await transaction.finish()
                print("Purchase successful for \(selectedOption.amount) tokens")
                return true
                
            case .pending:
                errorMessage = "Purchase is pending approval. Tokens will be added once approved."
                showError = true
                return true

            case .userCancelled:
                print("User cancelled the purchase")
                
            @unknown default:
                errorMessage = "Unknown purchase result. Please contact support."
                showError = true
                throw PaymentError.unknownPurchaseResult
            }
            
        } catch StoreKitError.userCancelled {
            // User cancelled, no error needed
            print("Purchase cancelled by user")
        } catch {
            print("Purchase failed with error: \(error.localizedDescription)")
            errorMessage = "Purchase failed. Please try again."
            showError = true
            throw error
        }
        
        return false
    }
    
    // MARK: - Transaction Processing
    
    /// Process a successful purchase by adding tokens to user's account
    private func processPurchase(transaction: Transaction, tokenAmount: Int) async {
        do {
            // Use the actual StoreKit transaction ID
            let transactionId = String(transaction.id)
            
            // Add tokens using your existing token service
            _ = try await tokenService.purchaseTokens(
                forUserWithId: userId,
                amount: tokenAmount,
                transactionId: transactionId
            )
        } catch {
            // Log failed token addition
            print("Failed to add tokens after successful payment: \(error)")
            errorMessage = "Purchase successful but tokens could not be added. Please contact support with transaction ID: \(transaction.id)"
            showError = true
        }
    }
    
    /// Verify StoreKit transaction
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            print("Transaction verification failed: \(error)")
            throw PaymentError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    
                    if let option = PurchaseOption.allCases.first(where: { $0.productId == transaction.productID }) {
                        await self.processPurchase(
                            transaction: transaction,
                            tokenAmount: option.amount
                        )
                    }
                    
                    await transaction.finish()
                    
                } catch {
                    print("Transaction listener error: \(error)")
                }
            }
        }
    }
    
    /// Check for any unfinished transactions on app launch
    private func checkForUnfinishedTransactions() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if this transaction needs processing
                if transaction.revocationDate == nil {
                    if let option = PurchaseOption.allCases.first(where: { $0.productId == transaction.productID }) {
                        await processPurchase(
                            transaction: transaction,
                            tokenAmount: option.amount
                        )
                    }
                }
                
                await transaction.finish()
                
            } catch {
                print("Error processing unfinished transaction: \(error)")
            }
        }
    }
    
    // MARK: - Restore Purchases
    
    /// Restore previous purchases
    func restorePurchases() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await checkForUnfinishedTransactions()
            
            errorMessage = "Purchases restored successfully"
            showError = true
        } catch {
            print("Restore purchases failed: \(error)")
            errorMessage = "Failed to restore purchases. Please try again."
            showError = true
        }
    }
    
}

// MARK: - Payment Errors
enum PaymentError: LocalizedError {
    case productNotFound
    case failedVerification
    case unknownPurchaseResult
    case tokenAdditionFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "The requested product could not be found."
        case .failedVerification:
            return "Transaction verification failed. Please contact support."
        case .unknownPurchaseResult:
            return "An unknown error occurred during purchase."
        case .tokenAdditionFailed(let reason):
            return "Failed to add tokens: \(reason)"
        }
    }
}
