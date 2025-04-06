//
//  LeaderboardView.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-05.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject private var dbService = DBService.shared
    @State private var users: [Profile] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var sortOption = SortOption.points
    
    enum SortOption: String, CaseIterable, Identifiable {
        case points = "Points"
        case distance = "Distance"
        case elevation = "Elevation"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Sorting options
                Picker("Sort By", selection: $sortOption) {
                    ForEach(SortOption.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: sortOption) { _ in
                    sortUsers()
                }
                
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
                    // Current user highlight
                    if let currentUser = dbService.user {
                        currentUserRankView(for: currentUser)
                    }
                    
                    // List of users
                    List {
                        ForEach(Array(users.enumerated()), id: \.element.id) { index, user in
                            LeaderboardRowView(
                                rank: index + 1,
                                user: user,
                                sortOption: sortOption,
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
                loadUsers()
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
        switch sortOption {
        case .points:
            users.sort { ($0.points ?? 0) > ($1.points ?? 0) }
        case .distance:
            users.sort { ($0.distanceHiked ?? 0) > ($1.distanceHiked ?? 0) }
        case .elevation:
            users.sort { ($0.elevationGained ?? 0) > ($1.elevationGained ?? 0) }
        }
    }
    
    @ViewBuilder
    private func currentUserRankView(for user: Profile) -> some View {
        if let userIndex = users.firstIndex(where: { $0.id == user.id }) {
            let rank = userIndex + 1
            
            HStack(spacing: 20) {
                VStack(alignment: .center) {
                    Text("#\(rank)")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Your Rank")
                        .font(.caption)
                }
                
                Divider()
                    .frame(height: 50)
                
                VStack(alignment: .leading) {
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.headline)
                    
                    switch sortOption {
                    case .points:
                        Text("\(user.points ?? 0) points")
                    case .distance:
                        Text("\(user.distanceHiked ?? 0) km hiked")
                    case .elevation:
                        Text("\(user.elevationGained ?? 0) m elevation")
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .padding(.horizontal)
        } else {
            Text("You're not on the leaderboard yet")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)
        }
    }
}

struct LeaderboardRowView: View {
    let rank: Int
    let user: Profile
    let sortOption: LeaderboardView.SortOption
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            // Rank
            Text("#\(rank)")
                .font(.headline)
                .frame(width: 40)
            
            // User
            HStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading) {
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text(user.email)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Value based on sort option
            Group {
                switch sortOption {
                case .points:
                    Text("\(user.points ?? 0)")
                        .fontWeight(.bold)
                case .distance:
                    Text("\(user.distanceHiked ?? 0) km")
                        .fontWeight(.bold)
                case .elevation:
                    Text("\(user.elevationGained ?? 0) m")
                        .fontWeight(.bold)
                }
            }
        }
        .padding(.vertical, 8)
        .background(isCurrentUser ? Color.blue.opacity(0.1) : Color.clear)
    }
}

#Preview {
    LeaderboardView()
}
