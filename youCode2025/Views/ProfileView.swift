//
//  ProfileView.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-05.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var dbService = DBService.shared
//    @State private var userGear: [UserGearItem] = []
    @State private var allGearItemsForUser: [GearItem] = []
    @State private var activeGearItemsForUser: [GearItem] = []
    @State private var isLoading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Top user info
                ZStack(alignment: .topTrailing) {
                    Color.accent
                        .frame(height: 150)

                    Button("setting") {}
                        .foregroundColor(.white)
                        .padding()
                }

                ZStack {
                    Circle()
                        .fill(Color.primaryText)
                        .frame(width: 120, height: 120)

                    if let urlString = dbService.user?.profilePhotoURL,
                       let imageURL = URL(string: urlString) {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } placeholder: {
                            ProgressView()
                                .frame(width: 120, height: 120)
                        }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -60)
                .padding(.bottom, -60)

                Text("\(dbService.user?.firstName ?? "User") \(dbService.user?.lastName.prefix(1) ?? "").")
                    .font(.title)
                    .bold()
                    .foregroundColor(.primaryText)

                HStack {
                    Text("Vancouver, BC")
                    Spacer()
                    if let createdDate = dbService.user?.created_at {
                        Text("Member since \(formattedYear(from: createdDate))")
                    } else {
                        Text("Member since 2023")
                    }
                }
                .foregroundColor(.primaryText)
                .padding(.horizontal)

                // Stats section
                HStack(spacing: 32) {
                    StatBlock(title: "ArcPoints", value: "\(dbService.user?.points ?? 0)")
                    StatBlock(title: "Level", value: "GOLD")
                    StatBlock(title: "Impact", value: "30km")
                }
                .padding()
                .background(Color.cardBackground)
                .cornerRadius(10)

                HStack {
                    StatLabel(title: "donations:")
                    Spacer()
                    StatLabel(title: "borrows: \(allGearItemsForUser.count)")
                }
                .padding(.horizontal)

                // Current Pieces Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Current Pieces")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.primaryText)

                    if isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else if allGearItemsForUser.isEmpty {
                        Text("No gear items found")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                            .background(Color.cardBackground)
                            .cornerRadius(10)
                    } else {
                        ForEach(activeGearItemsForUser) { item in
                            HStack {
                                Rectangle()
                                    .fill(Color.accent)
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)

                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.headline)
                                        .foregroundColor(.primaryText)
                                    Text("Condition: \(item.currentCondition)")
                                        .font(.subheadline)
                                        .foregroundColor(.primaryText.opacity(0.8))
                                    
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 8)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 6)
                            .background(Color.cardBackground)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .onAppear {
                Task {
                    do {
                        allGearItemsForUser = try await dbService.getGearItemsForUser(userId: dbService.user!.id)
                        activeGearItemsForUser = try await dbService.getActiveGearItemsForUser(userId: dbService.user!.id)
                        isLoading = false
                    } catch {
                        print("Error fetching users: \(error)")
                    }
                }
            }
        }
        .background(Color.background.edgesIgnoringSafeArea(.all))
    }

    private func loadUserGear() {
        guard let userId = dbService.user?.id else { return }

        isLoading = true

        Task {
            do {
//                let items = try await dbService.getUserGear(userId: userId)
//                let items = []
//
//                await MainActor.run {
//                    self.userGear = items
//                    self.isLoading = false
//                }
            } catch {
                print("Error loading user gear: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }

    private func formattedYear(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter.string(from: date)
    }
}

struct StatBlock: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.primaryText)
            Circle()
                .fill(Color.accent)
                .frame(width: 60, height: 60)
                .overlay(Text(value).bold().foregroundColor(.white))
        }
    }
}

struct StatLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .foregroundColor(.primaryText)
            .padding(8)
            .background(Color.cardBackground)
            .cornerRadius(6)
    }
}

#Preview {
    ProfileView()
}

extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }

    static let primaryText = Color(hex: 0x212120)
    static let accent = Color(hex: 0x434B43)
    static let cardBackground = Color(hex: 0xE7E0DA)
    static let background = Color(hex: 0xFFFCF5)
}
