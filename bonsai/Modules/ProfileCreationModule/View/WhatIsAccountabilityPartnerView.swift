import SwiftUI

struct WhatIsAccountabilityPartnerView: View {
    
    @State private var hobbies: [String] = []
    @State private var accountabilityPartnerName: String = ""
    @State private var accountabilityPartnerPhone: String = ""
    
    @FocusState private var isFieldFocused: Bool
    @AppStorage("isProfileCreated") private var isProfileCreated = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Text("Accountability Partner")
                    .font(.title)
                    .font(.system(size: 45))
                    .foregroundColor(.primary)
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                
                // Aligned container for all 3 sections
                VStack(alignment: .leading, spacing: 30) {
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("What is an Accountability Partner?")
                            .fontWeight(.bold)
                        
                        Text("Someone you choose to help you stay on track with your time limits and goals.")
                    }
                    .padding(.bottom, 5)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How does it work?")
                            .fontWeight(.bold)
                        
                        Text("When you hit your boundary time limit, you can trigger a request to your partner. They will be given a 6-digit code. If they share it with you, you’ll unlock 15 more minutes of screen time.")
                    }
                    .padding(.bottom, 5)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("How do I set it up?")
                            .fontWeight(.bold)
                        
                        Text("Simply enter their name and number; they’ll confirm via text to opt in, and your partnership is all set!")
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Text("Set Up Partner")
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.primary, lineWidth: 1)
                        )
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .navigationBarBackButtonHidden(true)
        .customBackToolbar()
    }
}

#Preview {
    WhatIsAccountabilityPartnerView()
}
