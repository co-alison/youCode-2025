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
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("arc")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Image("arcboth")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, -100)
                
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
                    
                    UnderlineButton(text: "Login", width: .infinity) {
                        Task {
                            do {
                                try await dbService.signIn(email: email, password: password)
                            } catch {
                                print("Authentication error: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.black)
                        
                        NavigationLink(destination: SignUpView()) {
                            Text("Sign Up")
                                .underline()
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .padding()
            }
        }
        .navigationTitle("Login")
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    LoginView()
}
