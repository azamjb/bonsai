//
//  OverrideBoundaryView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-05-03.
//

import SwiftUI

struct OverrideBoundaryView: View {
    @StateObject var viewModel: OverrideBoundaryViewModel = OverrideBoundaryViewModel()
    @ObservedObject var screenTime: ScreenTimeService
    @State private var isPaymentSheetPresented = false
    
    init(_ screenTime: ScreenTimeService) {
        self.screenTime = screenTime
    }

    var body: some View {
        
        ScrollView{
            VStack(alignment: .leading) {
                // Title stack with Crash!!
                ZStack(alignment: .leading) {
                    VStack(alignment: .leading) {
                        Text("CRASH")
                            .fontWeight(.heavy)
                            .font(.system(size: 80))
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                        
                        Text("OUT")
                            .fontWeight(.semibold)
                            .font(.system(size: 40))
                            .padding(.top, -70)
                            .padding(.horizontal, 10)
                            .zIndex(1)
                    }
                    
                    Image("crash_transparent_bgd")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 320, height: 170, alignment: .center)
                        .offset(x: -20, y: 125)
                        .zIndex(0)
                }
                .padding(.bottom, 120)
                
                VStack(alignment: .leading) {
                    Text("OVERRIDE TOKENS")
                        .fontWeight(.medium)
                        .font(.system(size: 20))
                     
                    Text("Override tokens will override all set boundaries until 12:00 am. ")
                        .font(.system(size: 12))
                        .padding(.bottom, 6)
                    
                    BonsaiButtonSmall(buttonText: " override limits ") {
                        Task {
                            let successfulSpend = await viewModel.spendToken(tokenSpendAmount: 1)
                            if successfulSpend {
                                screenTime.clearShieldedApps()
                            }
                        }
                    }
                    .padding(.bottom, 5)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    BonsaiButtonSmall(buttonText: "purchase tokens") {
                        isPaymentSheetPresented.toggle()
                    }
                    .padding(.bottom, 5)
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    NavigationLink(destination: FreqAskedQuestionsView(scrollToID: "manual_token_use")) {
                        VStack(alignment: .leading) {
                            Text("why tokens")
                                .font(.system(size: 12))
                                .underline()
                                .foregroundColor(Color(red: 0, green: 0.1, blue: 0.54))
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
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
                
                // TODO: TURN THIS INTO A BUTTON EVENTUALLY
                Text("where is my money going?")
                    .font(.system(size: 12))
                    .underline(true, pattern: .solid)
                    .foregroundColor(Color(red: 0, green: 0.04, blue: 0.54))
                    .frame(width: 165, alignment: .topLeading)
            }
            .padding(.horizontal, 45)
        }
        .sheet(isPresented: $isPaymentSheetPresented) {
            PurchaseTokenBottomSheetView()
                .presentationDetents([.fraction(0.60)])
        }
        .onChange(of: isPaymentSheetPresented) {
            if !isPaymentSheetPresented {
                viewModel.loadData()
            }
        }
        
        
    }
}



#Preview {
    var screenTime: ScreenTimeService = ScreenTimeService()
    OverrideBoundaryView(screenTime)
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
            
            HStack{
                Text("Transaction History")
                    .fontWeight(.semibold)
                    .font(.system(size: 9))
                    .foregroundColor(Color(red: 0.46, green: 0.46, blue: 0.46))
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                Spacer()
            }
            
            
            ScrollView {
                if !viewModel.tokenTransactions.isEmpty {
                    
                    
                    ForEach(viewModel.tokenTransactions) { transaction in
                        VStack(alignment: .leading){
                            Text("\(viewModel.makeSimpleDate(transaction.timestamp))")
                                .foregroundColor(Color(red: 0.42, green: 0.41, blue: 0.41))
                                .font(.system(size: 12))

                            HStack {
                                Text(viewModel.longFormTransactionType(transaction.type.rawValue.capitalized))
                                    .font(.system(size: 15))
                                    .foregroundColor(.primary)
                                Spacer()
                                let sign = transaction.netTokenChange >= 0 ? "+" : ""
                                Text("\(sign)\(transaction.netTokenChange)")
                                    .foregroundColor(transaction.netTokenChange >= 0 ? .green : .red)
                                    .font(.system(size: 18))
                            }
                            HStack{
                                Spacer()
                                Text("\(transaction.balanceAfterChange)")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.42, green: 0.41, blue: 0.41))

                            }
                            Divider()
                                .frame(width: 277, height: 1)
                                .background(Color(red: 0.67, green: 0.67, blue: 0.67))
                        }
                        
                    }
                } else {
                    Text("No transactions yet.")
                        .foregroundColor(.gray)
                        .padding(.top)
                }
            }
            .frame(height: 340)
            
            
        }
        .frame(width: 277)
        .padding(.top, 5)
        .onAppear {
            viewModel.loadData()
        }
    }
}


