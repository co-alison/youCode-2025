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
        NavigationView {
            ZStack {
                // Background image
                Image("arc")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Standardized spacing
                   // Spacer().frame(height: 0)
                    
                    // Arc logo image - centered
                    Image("arcboth")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, -100)
                
                    // Input fields
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .padding(.horizontal)
                        .padding(.top, 135)
                        .padding(.bottom, 8)
                        .accentColor(.black)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                        .accentColor(.black)
                    
                    // Login button
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
                            .foregroundColor(.white)
                            .font(.title2)
                            .padding()
                            .frame(width: 95, height: 35)
                            .background(Color.black)
                            .cornerRadius(10)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Sign-up link
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
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
            }
            .accentColor(.black)
        }
    }
}

#Preview {
    LoginView()
}
