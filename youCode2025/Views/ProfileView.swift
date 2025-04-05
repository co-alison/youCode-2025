//
//  ProfileView.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-05.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Top user info
                ZStack(alignment: .topTrailing) {
                    Color.gray.opacity(0.2)
                        .frame(height: 150)

                    Button("setting") {}
                        .padding()
                }

                // Profile circle
                Circle()
                    .fill(Color.gray)
                    .frame(width: 120, height: 120)
                    .offset(y: -60)
                    .padding(.bottom, -60)

                Text("Matt P.")
                    .font(.title)
                    .bold()

                HStack {
                    Text("Vancouver, BC")
                    Spacer()
                    Text("Member since 2023")
                }
                .padding(.horizontal)

                // Stats section
                HStack(spacing: 32) {
                    StatBlock(title: "ArcPoints", value: "872")
                    StatBlock(title: "Level", value: "GOLD")
                    StatBlock(title: "Impact", value: "30km")
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                HStack {
                    StatLabel(title: "donations:")
                    Spacer()
                    StatLabel(title: "borrows:")
                }
                .padding(.horizontal)

                // Current Pieces Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Current Pieces")
                        .font(.title2)
                        .bold()

                    ForEach(0..<3) { _ in
                        HStack {
                            Rectangle()
                                .fill(Color.gray)
                                .frame(width: 60, height: 60)
                                .cornerRadius(8)

                            Rectangle()
                                .fill(Color.gray.opacity(0.4))
                                .frame(height: 60)
                        }
                        .padding(.horizontal)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
}

struct StatBlock: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(title)
                .font(.subheadline)
            Circle()
                .fill(Color.gray)
                .frame(width: 60, height: 60)
                .overlay(Text(value).bold())
        }
    }
}

struct StatLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .padding()
            .background(Color.gray.opacity(0.4))
            .cornerRadius(6)
    }
}

#Preview {
    ProfileView()
}

