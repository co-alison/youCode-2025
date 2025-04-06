//
//  AuthView.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//

import SwiftUI
import PhotosUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isSignUp = false
    @State private var selectedImage: PhotosPickerItem?
    @State private var profileUIImage: UIImage?
    @ObservedObject private var dbService = DBService.shared
    
    var body: some View {
        VStack {
            Text(isSignUp ? "Sign Up" : "Login")
                .font(.largeTitle)
                .padding()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .padding()

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            if isSignUp {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Last Name", text: $lastName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                if let profileUIImage = profileUIImage {
                    Image(uiImage: profileUIImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .clipShape(Circle())
                        .padding()
                }
                
                PhotosPicker("Select Profile Photo", selection: $selectedImage, matching: .images)
                    .padding()
                    .onChange(of: selectedImage) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self),
                               let image = UIImage(data: data) {
                                profileUIImage = image
                            }
                        }
                    }
            }

            Button(isSignUp ? "Sign Up" : "Login") {
                Task {
                    do {
                        if isSignUp {
                            try await dbService.signUp(
                                email: email,
                                password: password,
                                firstName: firstName,
                                lastName: lastName,
                                profileUIImage: profileUIImage
                            )
                        } else {
                            try await dbService.signIn(email: email, password: password)
                        }
                    } catch {
                        print("Authentication error: \(error.localizedDescription)")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()

            Button(isSignUp ? "Already have an account? Login" : "Don't have an account? Sign Up") {
                isSignUp.toggle()
            }
            .padding()
        }
    }
}


#Preview {
    AuthView()
}
