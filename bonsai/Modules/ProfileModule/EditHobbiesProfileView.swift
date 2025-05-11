//
//  EditHobbiesProfileView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-03-08.
//

import SwiftUI

struct EditHobbiesProfileView: View {
    @Binding var hobbies: [String]
    @State private var hobbyList: [String] = []
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Text("Edit Hobbies")
                .font(.system(size: 20))
                .padding(.top, 20)
            
            List {
                ForEach(hobbyList.indices, id: \.self) { index in
                    TextField("Hobby \(index + 1)", text: $hobbyList[index])
                }
                .onDelete { indexSet in
                    hobbyList.remove(atOffsets: indexSet)
                }
                
                Button("Add Hobby") {
                    hobbyList.append("")
                }
                .padding(.vertical, 10)
            }
            

            
            Button("Save") {
                hobbies = hobbyList
                presentationMode.wrappedValue.dismiss()
            }
            .font(.system(size: 15))
            .foregroundColor(.white)
            .padding(.vertical, 10)
            .padding(.horizontal, 50)
            .background(Color.black)
            .cornerRadius(20)
        }
        .onAppear {
            // Convert the comma-separated string back into an array
            if !hobbies.isEmpty {
                hobbyList = hobbies
            }
        }
        .padding()
    }
}

#Preview {
    EditHobbiesProfileView(hobbies: .constant(["Hiking, Running"]))
}
