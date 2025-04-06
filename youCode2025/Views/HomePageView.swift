import SwiftUI

struct HomePageView: View {
    @StateObject private var dbService = DBService.shared
    @State private var gearItems: [GearItem] = []
    @State private var selectedTab = 0
    @State private var searchText: String = ""
    
    let gearTypes: [String] = GearItem.GearType.allCases.map { $0.rawValue.capitalized }
    
    var filteredItemsBySearch: [GearItem] {
        guard !searchText.isEmpty else {
            return gearItems
        }
        
        return gearItems.filter {
            $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            TextField("Search Gear...", text: .constant(""))
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                
                        
                        if (searchText.isEmpty) {
                            CategoryView(gearItems: gearItems, gearTypes: gearTypes)
                        }
                        
                        Button(action: {
                            selectedTab = 2
                        }) {
                            Text("Challenge of the month")
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        
                        Divider()
                        
                        Text("Nearby Gear")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(filteredItemsBySearch) { item in
                                GearItemView(gearItem: item)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top)
                }
                .navigationTitle("")
                .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(0)

            ReadTagView()
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Scan")
                }
                .tag(1)

            LeaderboardView()
                .tabItem {
                    Image(systemName: "list.number")
                    Text("Leaderboard")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(3)
        }
        .accentColor(.blue)
        .onAppear {
            Task {
                do {
                    gearItems = try await dbService.getAllGear()
                } catch {
                    print("Error fetching gear items: \(error)")
                }
            }
        }
    }
}

struct CategoryView: View {
    var gearItems: [GearItem]
    var gearTypes: [String]
    
    func filterItemsByType(for type: String) -> [GearItem] {
        return gearItems.filter { $0.type.rawValue.lowercased() == type.lowercased() }
    }
    
    var body: some View {
        VStack {
            Text("Browse Categories")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(gearTypes, id: \.self) { gearType in
                        NavigationLink(destination: GearsView(gearItems: filterItemsByType(for: gearType))) {
                            CategoryCard(title: gearType.rawValue.capitalized, imageName: gearType.rawValue)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CategoryCard: View {
    var title: String
    var imageName: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 140, height: 180)
                .cornerRadius(12)
                .overlay(
                    Text(title)
                        .fontWeight(.semibold)
                        .padding([.leading, .bottom], 8)
                        .foregroundColor(.white),
                    alignment: .bottomLeading
                )
        }
    }
}

// #Preview is useful for Xcode previews
#Preview {
    HomePageView()
}
