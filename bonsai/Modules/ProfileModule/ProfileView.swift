//
//  ProfileView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 0.5){
                Text("THE")
                    .fontWeight(.bold)
                HStack (spacing: 0.05){
                    Text("GREEN")
                        .foregroundColor(Color(red: 0.33, green: 0.6, blue: 0))
                        .fontWeight(.bold)
                    Text("HOUSE")
                        .fontWeight(.bold)
                }
                
            }
            .padding(.horizontal, 25)
            .frame(maxWidth: .infinity, alignment: .leading)
            .font(.system(size: 36))
            
            Spacer()
            
            
            Group{
                HStack{
                    Text("Profile")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 23))
                    Spacer()
                    Button(action: {
                        print("switch to edit screen")
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.black)
                            .font(.system(size: 27))
                    }
                }
                .padding(.bottom, 20)
                
                Text("Name:")
                Text(viewModel.userProfile.name)
                    .textCase(.uppercase)
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Text("Phone #:")
                Text(viewModel.userProfile.phoneNumber)
                    .font(.system(size: 22))
                Text("Hobbies")
                
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4),
                    spacing: 16
                ) {
                    ForEach(viewModel.userProfile.hobbies, id: \.self)
                    { hobby in hobbyTile(hobby: hobby)}
                }
            }
            .padding(.horizontal, 25)
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
            Group{
                HStack{
                    Text("Accountability Partner")
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                        .font(.title)
                    Spacer()
                    Button(action: {
                        print("switch to edit screen")
                    }) {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.black)
                            .font(.system(size: 27))
                    }
                }
                .padding(.bottom, 30)
                
                Text("Name:")
                Text(viewModel.userProfile.accountabilityPartner?.name ?? "Need to setup accountability partner")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .padding(.bottom, 10)
                
                Text("Phone #:")
                Text(viewModel.userProfile.accountabilityPartner?.phoneNumber ?? "")
                    .font(.system(size: 22))
                
            }
            .padding(.horizontal, 25)
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        .padding()
        .onAppear() {
            viewModel.fetchUserProfile()
        }
    }
    func hobbyTile(hobby: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.green)
                .frame(width: 80, height: 30)
            Text(hobby)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview{
    ProfileView()
}
