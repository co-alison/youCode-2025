//
//  LoginView.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-06.
//


import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @ObservedObject private var dbService = DBService.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var navigateToSignUp = false
    
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
                    
                    Button(action: {
                        Task {
                            do {
                                try await dbService.signIn(email: email, password: password)
                            } catch {
                                print("Authentication error: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text("Login")
                            .underline()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black)
                    .padding()
                    
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.black)
                        
                        NavigationLink(destination: SignUpView(), isActive: $navigateToSignUp) {
                            Button(action: {
                                navigateToSignUp = true
                            }) {
                                Text("Sign Up")
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
        LoginView()
    }
}
