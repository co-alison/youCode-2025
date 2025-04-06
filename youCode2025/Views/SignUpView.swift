//
//  SignUpView.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-06.
//

import SwiftUI
import PhotosUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var selectedImage: PhotosPickerItem?
    @State private var profileUIImage: UIImage?
    @ObservedObject private var dbService = DBService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToLogin = false
    
    var body: some View {
        ZStack {
            // Background image
            Image("arc")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            
            // Content with spacing to move login elements down
            ScrollView {
                VStack {
                    // Standardized spacing
                    Spacer().frame(height: 80)
                    
                    // Arc logo image - centered
                    Image("arcboth")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Input fields
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .accentColor(.black)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .accentColor(.black)
                    
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .accentColor(.black)
                    
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .accentColor(.black)
                    
                    if let profileUIImage = profileUIImage {
                        Image(uiImage: profileUIImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                            .clipShape(Circle())
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Text("Select Profile Photo")
                            .underline()
                    }
                    .padding()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onChange(of: selectedImage) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                profileUIImage = image
                            }
                        }
                    }
                    
                    Button(action: {
                        Task {
                            do {
                                try await dbService.signUp(
                                    email: email,
                                    password: password,
                                    firstName: firstName,
                                    lastName: lastName,
                                    profileUIImage: profileUIImage
                                )
                            } catch {
                                print("Authentication error: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text("Sign Up")
                            .underline()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black)
                    .padding()
                    .frame(width: 120, height: 70)
                    
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.black)
                        
                        NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                            Button(action: {
                                navigateToLogin = true
                            }) {
                                Text("Login")
                                    .underline()
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
            }
        }
        .accentColor(.black)
        .navigationBarBackButtonHidden(false)
    }
}

#Preview {
    NavigationView {
        SignUpView()
    }
}
