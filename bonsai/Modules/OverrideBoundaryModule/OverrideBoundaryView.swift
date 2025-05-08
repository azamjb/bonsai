//
//  OverrideBoundaryView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-05-03.
//

import SwiftUI

struct OverrideBoundaryView: View {
    @StateObject var viewModel: OverrideBoundaryViewModel = OverrideBoundaryViewModel()


    var body: some View {
        VStack(alignment: .leading) {
            // Title stack with Crash!!
            VStack(alignment: .leading) {
                Text("CRASH")
                    .fontWeight(.bold)
                    .font(.system(size: 80))
                Text("OUT")
                    .font(.system(size: 40))
                    .padding(.top,-70)
                    .padding(.horizontal, 10)
                
                Text("Crash will go here")
            }
            
            
            VStack(alignment: .leading) {
                Text("OVERRIDE TOKENS")
                    .fontWeight(.medium)
                    .font(.system(size: 20))
                
                Text("Override tokens will override all set boundaries until 12:00 am. ")
                    .font(.system(size: 12))
                    .padding(.bottom, 6)
                
                BonsaiNavLinkSmall(buttonText: "Override limits", destination: BoundaryExtensionRequestView())
                    .padding(.bottom, 5)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                BonsaiNavLinkSmall(buttonText: "purchase tokens", destination: BoundaryExtensionRequestView())
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Button ("Free Tokens"){
                    Task {
                        await viewModel.grantTokens(3)
                    }
                }

                // need to make this a page eventually
                Text("why tokens")
                    .font(.system(size: 12))
                    .underline()
                    .foregroundColor(Color(red: 0, green: 0.1, blue: 0.54))
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.vertical, 30)
            
            // Token Service Portal
            VStack(alignment: .leading) {
                Text("YOUR TOKENS")
                    .font(.system(size: 12))
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 277.00723, height: 1)
                    .background(.black)
            }
            
            // Inject the token service view here to prevent weird nesting issues
            TokenServiceView(viewModel)
            
        }
        .padding(.horizontal, 45)
        
    }
}



#Preview {
    OverrideBoundaryView()
}

struct TokenServiceView: View {
    @ObservedObject var viewModel: OverrideBoundaryViewModel
    
    init(_ viewModel: OverrideBoundaryViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Text("CURRENT")
                        .font(.system(size: 8))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.46))
                    Spacer()
                }
                
                // Position date at the right edge
                Text("\(viewModel.currentDate)")
                    .font(.system(size: 12))
                    .foregroundColor(Color(red: 0.42, green: 0.41, blue: 0.41))
            }
            
            // Center BALANCE
            Text("BALANCE")
                .font(.system(size: 8))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.46))
                .frame(maxWidth: .infinity, alignment: .center)
            
            // Center token balance value
            Text("\(viewModel.tokenBalance)")
                .font(.system(size: 48))
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ScrollView {
                if !viewModel.tokenTransactions.isEmpty {
                    Text("Transaction History")
                        .fontWeight(.medium)
                        .padding(.top, 20)
                    
                    ForEach(viewModel.tokenTransactions) { transaction in
                        HStack {
                            Text(transaction.type.rawValue.capitalized)
                            Spacer()
                            Text("\(transaction.netTokenChange)")
                                .foregroundColor(transaction.netTokenChange >= 0 ? .green : .red)
                        }
                        .padding(.vertical, 4)
                    }
                } else {
                    Text("No transactions yet.")
                        .foregroundColor(.gray)
                        .padding(.top)
                }
            }
            
            
        }
        .frame(width: 277)
        .padding(.top, 5)
        .onAppear {
            viewModel.loadData()
        }
    }
}
