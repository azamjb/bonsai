//
//  PurchaseTokenBottomSheetView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-05-19.
//

import SwiftUI
import StoreKit

enum PurchaseOption: String, CaseIterable, Identifiable {
    case one  = "1 token"
    case three = "3 tokens"
    case five  = "5 tokens"
    
    var id: Self { self }
    
    var amount: Int {
        switch self {
        case .one: return 1
        case .three: return 3
        case .five: return 5
        }
    }
    
    // Fallback prices for display when products aren't loaded
    var fallbackPrice: Decimal {
        switch self {
        case .one: return 1.29
        case .three: return 2.99
        case .five: return 3.99
        }
    }
    
    // Product IDs that match your StoreKit Configuration
    var productId: String {
        switch self {
        case .one: return "com.bonsai.inc.OverrideToken.One"
        case .three: return "com.bonsai.inc.OverrideToken.Three"
        case .five: return "com.bonsai.inc.OverrideToken.Five"
        }
    }
}

private let cadFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .currency
    f.currencyCode = "CAD"
    return f
}()

struct TokenPaymentRow: View {
    let option: PurchaseOption
    let isSelected: Bool
    let product: Product?
    
    private var priceText: String {
        if let product = product {
            // Use StoreKit's formatted price
            return product.displayPrice
        } else {
            // Fallback to manual formatting
            return cadFormatter.string(from: option.fallbackPrice as NSDecimalNumber) ?? "$\(option.fallbackPrice)"
        }
    }
    
    private var descriptionText: String? {
        if let product = product {
            return product.description
        }
        return nil
    }
    
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                .imageScale(.large)
            
            Text(option.rawValue)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(priceText)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct PurchaseTokenBottomSheetView: View {
    @State private var selected: PurchaseOption = .one
    @StateObject private var viewModel = PaymentViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            Text("Purchase Override Tokens")
                .font(.system(size: 20, weight: .semibold))
                .padding(.top, 35)
            
            Divider()
                .background(Color(.systemBackground))
            
            Text("When redeemed, override tokens will override all set boundaries until 12:00 AM.")
                .font(.system(size: 12))
                .opacity(0.8)
            
            // Product Options - Always show them, even while loading
            VStack(spacing: 12) {
                ForEach(PurchaseOption.allCases) { option in
                    Button {
                        selected = option
                    } label: {
                        TokenPaymentRow(
                            option: option,
                            isSelected: option == selected,
                            product: viewModel.product(for: option)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(viewModel.isPurchasing)
                }
            }
            .padding(.vertical, 8)
            
            BonsaiButtonRegular(
                contrastedColorTheme: false,
                buttonText: viewModel.isPurchasing ? "Processing..." : "Purchase"
            ) {
                Task {
                    do {
                        print("🎯 Attempting to purchase: \(selected.rawValue) with product ID: \(selected.productId)")
                        var result = try await viewModel.purchaseSelectedTokenBundle(selectedOption: selected)
                        if result && !viewModel.showError {
                            dismiss()
                        }
                    } catch {
                        // Error is handled in viewModel
                        print("Purchase error: \(error)")
                    }
                }
            }
            .disabled(viewModel.isPurchasing)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.top)
            
            // Restore Purchases Button
            Button(action: {
                Task {
                    await viewModel.restorePurchases()
                }
            }) {
                Text("Restore Purchases")
                    .font(.footnote)
                    .opacity(0.7)
                    .frame(maxWidth: .infinity)
            }
            .disabled(viewModel.isPurchasing || viewModel.isLoading)
            
            Spacer()
        }
        .padding(.horizontal, 35)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundColor(Color(.label))
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .edgesIgnoringSafeArea(.bottom)
        .alert("Purchase Status", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {
                if viewModel.errorMessage?.contains("restored successfully") == true {
                    dismiss()
                }
            }
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred")
        }
        .task {
            await viewModel.loadProducts()
        }
    }
}

#Preview {
    PurchaseTokenBottomSheetView()
}
