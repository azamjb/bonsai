//
//  PurchaseTokenBottomSheetView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-05-19.
//

import SwiftUI

enum PurchaseOption: String, CaseIterable, Identifiable {
    case one  = "1 token"
    case three = "3 tokens"
    case five  = "5 tokens"
    
    var id: Self { self }
    
    var cost: Decimal {
        switch self {
        case .one: 1.29
        case .three: 2.99
        case .five: 3.99
        }
    }
    
    var amount: Int {
        switch self {
        case .one: 1
        case .three: 3
        case .five: 5
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
    
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
                .imageScale(.large)
            
            Text(option.rawValue)
                .fontWeight(.medium)
            
            Spacer()
            
            Text(cadFormatter.string(from: option.cost as NSDecimalNumber)!)
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
    @StateObject var viewModel: PaymentViewModel = PaymentViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Purchase Override Tokens")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(.systemBackground))
                .padding(.top, 35)
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 331, height: 3)
                .background(.white)
            
            Text("When redeemed, override tokens will override all set boundaries until 12:00 AM.")
                .font(.system(size: 12))
                .foregroundColor(Color(.systemBackground))
            
            ForEach(PurchaseOption.allCases) { option in
                Button { selected = option } label: {
                    TokenPaymentRow(option: option, isSelected: option == selected)
                }
                .buttonStyle(.plain)
            }
            
            BonsaiButtonRegular(contrastedColorTheme: true, buttonText: "Purchase") {
                Task {
                    try await viewModel.purchaseSelectedTokenBundle(selectedOption: selected)
                    dismiss()
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            
            Spacer()
        }
        .padding(.horizontal, 35)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.label))
        .cornerRadius(20)
        .shadow(radius: 10)
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview{
    PurchaseTokenBottomSheetView()
    
}
