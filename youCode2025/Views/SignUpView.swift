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
                    // Spacer to push content down
                    Spacer().frame(height: 350)
                    
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
                    }
                    
                    
                    PhotosPicker(selection: $selectedImage, matching: .images) {
                        Text("Select Profile Photo")
                            .underline()
                    }
                    .padding()
                    .foregroundColor(.black)
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
