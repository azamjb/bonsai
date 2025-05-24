//
//  FreqAskedQuestionsView.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-03-27.
//

import SwiftUI

struct FreqAskedQuestionsView: View {
    var scrollToID: String? = nil
    @State private var expandedID: String? = nil
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack {
                    Text("FAQ")
                        .font(.system(size: 25))
                        .padding(.top, 15)
                        .padding(.bottom, 55)
                    
                    ForEach(faqItems, id: \.id) { item in
                        ExpandableItemView(
                            id: item.id,
                            title: item.title,
                            description: item.description,
                            expandedID: $expandedID
                        )
                        .id(item.id) // anchor for scrolling
                    }
                }
                .padding(.horizontal, 40)
            }
            .onAppear {
                if let id = scrollToID {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation {
                            proxy.scrollTo(id, anchor: .top)
                            expandedID = id
                        }
                    }
                }
            }
            .customBackToolbar()
        }
    }
}

struct ExpandableItemView: View {
    let id: String
    let title: String
    let description: String
    @Binding var expandedID: String?
    
    var isExpanded: Bool {
        expandedID == id
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(title)
                    .font(.system(size: 16))
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.gray)
            }
            .onTapGesture {
                withAnimation {
                    expandedID = isExpanded ? nil : id
                }
            }
            
            if isExpanded {
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
        }
        .padding(.bottom, 55)
    }
}

#Preview{
    FreqAskedQuestionsView()
}

struct FAQItem {
    let id: String
    let title: String
    let description: String
}

let faqItems: [FAQItem] = [
    FAQItem(
        id: "what_is_boundary",
        title: "What is a boundary?",
        description: "A boundary is a customizable daily screen time limit you set for specific app groups or categories. It helps you take control of your time by automatically restricting access once you hit your daily limit."
    ),
    FAQItem(
        id: "create_boundary",
        title: "How can I create a boundary?",
        description: "To set a boundary, go to the 'Boundaries' tab and press 'Add New Boundary.' You can choose which apps to monitor, how much daily time you allow, and which days of the week are monitored. Keep in mind — you can only create, edit, or delete boundaries twice per week."
    ),
    FAQItem(
        id: "what_is_partner",
        title: "What is an accountability partner?",
        description: "An accountability partner is someone you trust to keep you on track with your screen time goals. When you reach a limit on a boundary, if you want more time on an app without waiting till the next day, you need to request it from your accountability partner."
    ),
    FAQItem(
        id: "how_many_partners",
        title: "How many accountability partners can I have?",
        description: "You can have one accountability partner at a time. An accountability partner is needed to use the main features of the app."
    ),
    FAQItem(
        id: "who_should_partner",
        title: "Who should my accountability partner be?",
        description: "Your accountability partner can be a friend, family member, or anyone with a genuine interest in your wellbeing, who is willing to help you break bad habits!"
    ),
    FAQItem(
        id: "partner_grant_time",
        title: "How can my accountability partner grant me more time?",
        description: "If you hit your daily limit, go to the 'Request Boundary Extension' section, select the boundary you want to extend, and request a code. Your partner will get a 6-digit code via SMS — if they approve, they’ll share it with you. Enter the code to unlock 15 extra minutes for that day."
    ),
    FAQItem(
        id: "does_partner_need_app",
        title: "Does my accountability partner need to download the app?",
        description: "Nope! Your accountability partner will only be involved through SMS, making the process simple and low-effort!!"
    ),
    FAQItem(
        id: "partner_on_vacation",
        title: "What should I do if my accountability partner is on vacation?",
        description: "If your partner is temporarily unavailable, you can temporarily remove your boundaries. Just remember to re-make them once your partner is ready to support you again."
    ),
    FAQItem(
        id: "manual_token_use",
        title: "What is a manual override token used for?",
        description: "A manual override token gives you full access to all your apps for the rest of the day. It’s meant for emergencies or situations where your partner isn't around to approve extra time."
    ),
    FAQItem(
        id: "manual_token_obtain",
        title: "How can I obtain a manual override token?",
        description: "You can purchase override tokens in packs of 3 or 5 from the 'Override Boundaries' page. Use them sparingly!"
    ),
    FAQItem(
        id: "cost_tokens",
        title: "Why is there a cost for manual override tokens?",
        description: "Charging for override tokens adds a small barrier that encourages you to pause and reflect before bypassing your boundaries. It’s a gentle nudge toward more intentional screen time decisions — without making the app too restrictive."
    )
]

