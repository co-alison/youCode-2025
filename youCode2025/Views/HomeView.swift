//
//  HomeView.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var dbService = DBService.shared
    
    var body: some View {
        VStack {
            Text("Welcome, \(dbService.user?.email ?? "User")!")
                .font(.title)
                .padding()

            Button("Sign Out") {
                Task {
                    do {
                        try await dbService.signOut()
                    } catch {
                        print("Sign out error: \(error.localizedDescription)")
                    }
                }
            }
            .buttonStyle(.bordered)

        }
    }
}

#Preview {
    HomeView()
}
