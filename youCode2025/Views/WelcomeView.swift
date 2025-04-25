//
//  WelcomeView.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-06.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView { // TODO: this can just be an if/else with 2 views
            ZStack {
                Image("arc")
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer().frame(height: 100)

                    Image("arcboth")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Spacer().frame(height: 40)

                    VStack(spacing: 20) {
                        NavigationLink(destination: LoginView()) {
                            NavigationText(text: "Login")
                        }

                        NavigationLink(destination: SignUpView()) {
                            NavigationText(text: "Sign Up")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)

                    Spacer()
                }
                .padding()
            }
            .accentColor(.black)
        }
    }
}

extension WelcomeView {
    
}

#Preview {
    WelcomeView()
}
