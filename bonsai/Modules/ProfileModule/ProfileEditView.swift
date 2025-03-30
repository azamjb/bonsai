//
//  ProfileView.swift
//  bonsai
//
//  Created by Nicolas Mingorance-Geraldo on 2025-01-11.
//

import SwiftUI

struct ProfileEditView: View {
    
    @StateObject var viewModel: ProfileViewModel = ProfileViewModel()
    @ObservedObject var editModel: ProfileCreationViewModel = ProfileCreationViewModel()
    
    // Original values from the database
    @State private var originalName: String = ""
    @State private var originalPhone: String = ""
    @State private var originalHobbies: [String] = []
    
    // Current edited values
    @State private var editedName: String = ""
    @State private var editedPhone: String = ""
    @State private var editedHobbies: [String] = []
    
    @State private var isSaved: Bool = false
    @State private var hasLoadedInitialData: Bool = false
    
    // Computed properties to check if values have changed
    private var nameChanged: Bool { originalName != editedName }
    private var phoneChanged: Bool { originalPhone != editedPhone }
    private var hobbiesChanged: Bool { originalHobbies != editedHobbies }
    private var hasChanges: Bool { nameChanged || phoneChanged || hobbiesChanged }
    
    // Navigation overlay variables
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDiscardAlert = false
    
    var body: some View {
        ScrollView {
            VStack {
                Text("PROFILE EDITOR")
                    .font(.system(size: 25))
                    .padding(.top, 30)
                    .padding(.bottom, 45)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("NAME")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        if nameChanged {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 12))
                        }
                    }
                    
                    TextField(originalName, text: $editedName)
                        .padding(.bottom, 5)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(nameChanged ? .blue : .black)
                }
                .padding(.bottom, 30)
                
                VStack(alignment: .leading) {
                    HStack {
                        Text("PHONE")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                        
                        if phoneChanged {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 12))
                        }
                    }
                    
                    TextField(originalPhone, text: $editedPhone)
                        .padding(.bottom, 5)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(phoneChanged ? .blue : .black)
                }
                .padding(.bottom, 30)
                
                NavigationLink(destination: EditHobbiesProfileView(hobbies: $editedHobbies)) {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("OBJECTIVES")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                            
                            if hobbiesChanged {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 12))
                            }
                        }

                        Text(editedHobbies.isEmpty ? "Add hobbies..." : editedHobbies.joined(separator: ", "))
                            .foregroundColor(.black)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.leading)
                            .padding(.bottom, 5)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.bottom, 40)
                
                HStack(spacing: 20) {
                    // Only show reset button if changes exist
                    if hasChanges {
                        Button("Reset") {
                            resetToOriginalValues()
                        }
                        .font(.system(size: 15))
                        .foregroundColor(.red)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.red, lineWidth: 1)
                        )
                    }
                    
                    Button("Save") {
                        viewModel.saveBasicInfo(name: editedName, phoneNumber: editedPhone, hobbies: editedHobbies)
//                        viewModel.saveHobbies(hobbies: editedHobbies)
                        
                        // Update original values to match edited values
                        originalName = editedName
                        originalPhone = editedPhone
                        originalHobbies = editedHobbies
                        
                        isSaved = true
                    }
                    .font(.system(size: 15))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 40)
                    .background(hasChanges ? Color.blue : Color.gray)
                    .cornerRadius(20)
                    .disabled(!hasChanges)
                }
                
                if isSaved {
                    Text("Changes saved successfully!")
                        .foregroundColor(.green)
                        .padding(.top, 10)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                isSaved = false
                            }
                        }
                }
            }
            .padding(.horizontal,35)
            .onAppear() {
                // Only load data from database if we haven't loaded it before
                if !hasLoadedInitialData {
                    loadInitialData()
                    hasLoadedInitialData = true
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            if hasChanges {
                showingDiscardAlert = true
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Back")
            }
        })
        .alert(isPresented: $showingDiscardAlert) {
            Alert(
                title: Text("Unsaved Changes"),
                message: Text("You have unsaved changes. Are you sure you want to go back?"),
                primaryButton: .destructive(Text("Discard Changes")) {
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel()
            )
        }
        .interactiveDismissDisabled(hasChanges)
    }
    
    // Helper function to load initial data from database
    private func loadInitialData() {
        viewModel.fetchUserProfile()
        
        // Set both original and edited values
        originalName = viewModel.userProfile.name
        originalPhone = viewModel.userProfile.phoneNumber
        originalHobbies = viewModel.userProfile.hobbies

        editedName = originalName
        editedPhone = originalPhone
        editedHobbies = originalHobbies
    }

    // we don't have to use this but kinda nice to be able to restor to database defaults
    private func resetToOriginalValues() {
        editedName = originalName
        editedPhone = originalPhone
        editedHobbies = originalHobbies
    }
}

#Preview{
    ProfileEditView()
}
