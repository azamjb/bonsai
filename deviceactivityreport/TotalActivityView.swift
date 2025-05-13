//
//  TotalActivityView.swift
//  deviceactivityreport
//
//  Created by Azam Jawad on 2024-11-29.
//

import SwiftUI

struct TotalActivityView: View {
    let totalActivity: String  

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                formatTotalActivityText(totalActivity)
            }
        }
    }

    func formatTotalActivityText(_ text: String) -> some View {
        let components = text.split(separator: " ")

        return HStack(spacing: 12) {
            ForEach(components, id: \.self) { component in
                if let numberPart = component.first(where: { $0.isNumber }) {
                    let unitPart = component.drop { $0.isNumber }
                    
                    HStack(alignment: .lastTextBaseline) {
                        Text(String(numberPart))
                            .font(.system(size: 60, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text(String(unitPart))
                            .font(.system(size: 30, weight: .regular))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }

}


// In order to support previews for your extension's custom views, make sure its source files are
// members of your app's Xcode target as well as members of your extension's target. You can use
// Xcode's File Inspector to modify a file's Target Membership.
#Preview {
    TotalActivityView(totalActivity: "1h 23m")
}
