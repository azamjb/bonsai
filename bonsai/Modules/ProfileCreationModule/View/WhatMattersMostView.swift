//
//  whatMattersMostView.swift
//  bonsai
//
//  Created by Azam Jawad on 2025-03-07.
//

import SwiftUI

struct WhatMattersMostView: View {
    
    @ObservedObject var viewModel: ProfileCreationViewModel = ProfileCreationViewModel()
    @Environment(\.presentationMode) var presentationMode 
    
    @State var hobbies: [String] = []
    @State var screenTime: String
    
    let systemHobbies = ["Friends", "Family", "Self Care", "Education", "New Skills", "Fitness", "Career", "Projects", "Creativity", "Rest"]
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("What matters most to you?")
                    .padding(.top, 100)
                Text("Choose up to 5 areas to reallocate your time and start living with purpose.")
                    .padding(.top, 10)
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                
                HStack {
                    
                    Spacer()
                    Spacer()
                    
                    hobbyTile(
                        hobby: systemHobbies[0],
                        color: "#81CEB7",
                        isSelected: hobbies.contains(systemHobbies[0]),
                        onTap: {
                            if hobbies.contains(systemHobbies[0]) {
                                hobbies.removeAll { $0 == systemHobbies[0] }
                            } else if hobbies.count < 5 {
                                hobbies.append(systemHobbies[0])
                            }
                        }
                    )
                    Spacer()
                    
                    hobbyTile(
                        hobby: systemHobbies[1],
                        color: "#81CEB7",
                        isSelected: hobbies.contains(systemHobbies[1]),
                        onTap: {
                            if hobbies.contains(systemHobbies[1]) {
                                hobbies.removeAll { $0 == systemHobbies[1] }
                            } else if hobbies.count < 5 {
                                hobbies.append(systemHobbies[1])
                            }
                        }
                    )
                    
                    Spacer()
                    Spacer()
                    
                }
                
                Spacer()
                
                HStack {
                    
                    Spacer()
                    Spacer()
                    
                    hobbyTile(
                        hobby: systemHobbies[2],
                        color: "#31B788",
                        isSelected: hobbies.contains(systemHobbies[2]),
                        onTap: {
                            if hobbies.contains(systemHobbies[2]) {
                                hobbies.removeAll { $0 == systemHobbies[2] }
                            } else if hobbies.count < 5 {
                                hobbies.append(systemHobbies[2])
                            }
                        }
                    )
                    Spacer()
                    
                    hobbyTile(
                        hobby: systemHobbies[3],
                        color: "#31B788",
                        isSelected: hobbies.contains(systemHobbies[3]),
                        onTap: {
                            if hobbies.contains(systemHobbies[3]) {
                                hobbies.removeAll { $0 == systemHobbies[3] }
                            } else if hobbies.count < 5 {
                                hobbies.append(systemHobbies[3])
                            }
                        }
                    )
                    Spacer()
                    Spacer()
                    
                }
                Spacer()
                
                HStack {
                    
                    Spacer()
                    Spacer()
                    
                    hobbyTile(
                        hobby: systemHobbies[4],
                        color: "#148E63",
                        isSelected: hobbies.contains(systemHobbies[4]),
                        onTap: {
                            if hobbies.contains(systemHobbies[4]) {
                                hobbies.removeAll { $0 == systemHobbies[4] }
                            } else if hobbies.count < 5 {
                                hobbies.append(systemHobbies[4])
                            }
                        }
                    )
                    
                    Spacer()
                    
                    hobbyTile(
                        hobby: systemHobbies[5],
                        color: "#148E63",
                        isSelected: hobbies.contains(systemHobbies[5]),
                        onTap: {
                            if hobbies.contains(systemHobbies[5]) {
                                hobbies.removeAll { $0 == systemHobbies[5] }
                            } else if hobbies.count < 5 {
                                hobbies.append(systemHobbies[5])
                            }
                        }
                    )
                    
                    Spacer()
                    Spacer()
                    
                }
                Spacer()
                
                HStack {
                    
                    Spacer()
                    Spacer()
                    
                    hobbyTile(
                        hobby: systemHobbies[6],
                        color: "#0E7362",
                        isSelected: hobbies.contains(systemHobbies[6]),
                        onTap: {
                            if hobbies.contains(systemHobbies[6]) {
                                hobbies.removeAll { $0 == systemHobbies[6] }
                            } else if hobbies.count < 5 {
                                hobbies.append(systemHobbies[6])
                            }
                        }
                    )
                    
                    Spacer()
                    
                    hobbyTile(
                        hobby: systemHobbies[7],
                        color: "#0E7362",
                        isSelected: hobbies.contains(systemHobbies[7]),
                        onTap: {
                            if hobbies.contains(systemHobbies[7]) {
                                hobbies.removeAll { $0 == systemHobbies[7] }
                            } else if hobbies.count < 5 {
                                hobbies.append(systemHobbies[7])
                            }
                        }
                    )
                    
                    Spacer()
                    Spacer()
                    
                }
                
                Spacer()
                
                let forwardButton = Image(systemName: "chevron.right")
                    .font(.system(size: 18))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.black)
                    .clipShape(Circle())

                NavigationLink(destination: PastUsageInspireView(screenTime: screenTime, hobbies: hobbies)) {
                    forwardButton
                }
                .padding(.leading, 200)
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                    }
                }
            }
        }
        
    }
    
    
    func screenTimeButton(title: String, color: String) -> some View {
        Button(action: {
            screenTime = title
        }) {
            Text(title)
                .padding(.horizontal, 80)
                .padding(.vertical, 8)
                .background(Color(hex: color))
                .foregroundColor(.white)
                .cornerRadius(20)
                .fontWeight(.bold)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(screenTime == title ? Color.black : Color.clear, lineWidth: 1)
                )
        }
        .padding(.bottom, 20)
    }
    
    func hobbyTile(hobby: String, color: String, isSelected: Bool, onTap: @escaping () -> Void) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color(hex: color))
                .frame(width: 140, height: 50)
                .overlay( // ✅ Adds border only if selected
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(isSelected ? Color.black : Color.clear, lineWidth: 1)
                )
            
            Text(hobby)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .onTapGesture {
            onTap()
        }
    }

}



#Preview {
    WhatMattersMostView(screenTime: "5 hours")
}
