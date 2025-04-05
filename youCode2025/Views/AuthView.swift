//
//  AuthView.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//

import SwiftUI

struct AuthView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isSignUp = false
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
            }

            Button(isSignUp ? "Sign Up" : "Login") {
                Task {
                    do {
                        if isSignUp {
                            try await dbService.signUp(
                                email: email,
                                password: password,
                                firstName: firstName,
                                lastName: lastName
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
