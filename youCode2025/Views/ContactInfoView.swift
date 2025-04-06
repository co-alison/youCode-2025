//  ContactInfoView.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-06.
//

import SwiftUI

struct ContactInfoView: View {
    @ObservedObject private var dbService = DBService.shared
    
    var body: some View {
        ScrollView {
            if let user = dbService.user {
                VStack(spacing: 20) {
                    // Top banner
                    Color.accent
                        .frame(height: 150)
                        .overlay(
                            Text("Contact Info")
                                .font(.title2)
                                .bold()
                                .foregroundColor(.white)
                                .padding(.top, 40),
                            alignment: .top
                        )

                    // Profile Picture
                    Circle()
                        .fill(Color.primaryText)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 40))
                        )
                        .offset(y: -50)
                        .padding(.bottom, -50)

                    Text("\(user.firstName) \(user.lastName)")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primaryText)

                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(label: "Email", value: user.email)
                        
                        // Just include total points
                        InfoRow(label: "Total Points", value: "\(user.points ?? 0)")
                        
                        if let joinedDate = user.created_at {
                            InfoRow(label: "Member since", value: formattedDate(from: joinedDate))
                        }
                    }
                    .padding()
                    .background(Color.cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            } else {
                VStack {
                    Text("Please sign in to view your profile")
                        .foregroundColor(.primaryText)
                        .padding()
                    
                    ProgressView()
                }
                .frame(maxHeight: .infinity)
            }
//            .padding(.vertical)
        }
        .background(Color.background.edgesIgnoringSafeArea(.all))
    }

    private func formattedDate(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    var label: String
    var value: String

    var body: some View {
        HStack {
            Text(label + ":")
                .bold()
                .foregroundColor(.primaryText)
            Spacer()
            Text(value)
                .foregroundColor(.primaryText)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ContactInfoView()
}
