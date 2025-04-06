//
//  WelcomeView.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-06.
//


import SwiftUI

struct WelcomeView: View {
    @State private var navigateToSignIn = false
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
                    Spacer().frame(height: 350)
                    
                    VStack(spacing: 20) {
                        NavigationLink(destination: LoginView(), isActive: $navigateToSignIn) {
                            Text("Login")
                                .underline()
                                .foregroundColor(.white)
                                .font(.title2)
                                .padding()
                                .frame(width: 150)
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                        
                        NavigationLink(destination: SignUpView(), isActive: $navigateToSignUp) {
                            Text("Sign Up")
                                .underline()
                                .foregroundColor(.white)
                                .font(.title2)
                                .padding()

                                .frame(width: 150)
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .accentColor(.black)
        }
    }
}

#Preview {
    WelcomeView()
}
