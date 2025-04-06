//
//  LeaderboardView.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-05.
//

import SwiftUI

struct LeaderboardView: View {
    @Binding var selectedTab: Int
    @ObservedObject private var dbService = DBService.shared
    @State private var users: [Profile] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading leaderboard...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    VStack {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text(error)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            loadUsers()
                        }
                        .padding(.top)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if users.isEmpty {
                    VStack {
                        Image(systemName: "person.3")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("No users found")
                        Button("Refresh") {
                            loadUsers()
                        }
                        .padding(.top)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    TopThreeView(users: Array(users.prefix(3)))

                    List {
                        ForEach(Array(users.dropFirst(3).enumerated()), id: \.element.id) { index, user in
                            LeaderboardRowView(
                                rank: index + 4,
                                user: user,
                                isCurrentUser: user.id == dbService.user?.id
                            )
                        }
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await refreshData()
                    }
                }
            }
            .navigationTitle("Leaderboard")
            .onAppear {
                Task {
                    do {
                        users = try await dbService.getUsers()
                        sortUsers()
                        isLoading = false
                    } catch {
                        print("Error fetching users: \(error)")
                    }
                }
            }
            .onChange(of: selectedTab) { newTab in
                if newTab == 2 {
                    Task {
                        do {
                            users = try await dbService.getUsers()
                            sortUsers()
                            isLoading = false
                        } catch {
                            print("Error fetching users: \(error)")
                        }
                    }
                }
            }
        }
    }

    private func loadUsers() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let fetchedUsers = try await dbService.getUsers()

                await MainActor.run {
                    self.users = fetchedUsers
                    sortUsers()
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to load users: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }

    private func refreshData() async {
        do {
            let fetchedUsers = try await dbService.getUsers()

            await MainActor.run {
                self.users = fetchedUsers
                sortUsers()
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to refresh data"
            }
        }
    }

    private func sortUsers() {
        users.sort { ($0.points ?? 0) > ($1.points ?? 0) }
    }
}

struct TopThreeView: View {
    let users: [Profile]

    var body: some View {
        HStack(spacing: 20) {
            if users.count > 1 {
                TopUserView(user: users[1], rank: 2, size: 80)
            }

            if users.count > 0 {
                TopUserView(user: users[0], rank: 1, size: 100, showCrown: true)
            }

            if users.count > 2 {
                TopUserView(user: users[2], rank: 3, size: 80)
            }
        }
        .padding()
    }
}

struct TopUserView: View {
    let user: Profile
    let rank: Int
    let size: CGFloat
    var showCrown: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .top) {
                Circle()
                    .fill(Color.gray)
                    .frame(width: size, height: size)

                if showCrown {
                    Image("winner")
                        .resizable()
                        .frame(width: 60, height: 60) // doubled size
                        .offset(y: -30) // adjusted offset
                }

                Text("\(rank)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.black)
                    .clipShape(Circle())
                    .offset(y: size / 2 - 10)
            }

            Text("\(user.firstName) \(user.lastName.prefix(1)).")
                .fontWeight(.medium)

            Text("\(user.points ?? 0) points")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct LeaderboardRowView: View {
    let rank: Int
    let user: Profile
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            Text("\(rank)")
                .font(.title3)
                .bold()

            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 32, height: 32)

            Text("\(user.firstName) \(user.lastName)")
                .font(.body)

            Spacer()

            Text("\(user.points ?? 0) points")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
        .background(isCurrentUser ? Color.blue.opacity(0.1) : Color.clear)
    }
}

#Preview {
//    LeaderboardView()
}
