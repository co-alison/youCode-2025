import SwiftUI

struct HomePageView: View {
    @ObservedObject private var dbService = DBService.shared
    @State private var gearItems: [GearItem] = []
    @State private var selectedTab = 0
    @State private var searchText: String = ""
    @State private var userNeedsRefresh: Bool = false
    
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
                            Text("Borrow or exchange 5 times!")
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
                        
                        ListView(gearItems: gearItems)
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

            ReadTagView(userNeedsRefresh: $userNeedsRefresh, selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "camera.fill")
                    Text("Scan")
                }
                .tag(1)

            LeaderboardView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "list.number")
                    Text("Leaderboard")
                }
                .tag(2)

            ProfileView(selectedTab: $selectedTab, userNeedsRefresh: $userNeedsRefresh)
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
        .onChange(of: selectedTab) { newTab in
            if newTab == 0 {
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
                        NavigationLink(destination: GearsView(gearItems: filterItemsByType(for: gearType), gearType: gearType)) {
                            CategoryCard(title: gearType, imageName: gearType.lowercased())
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
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 140, height: 180)
                .clipped()
                .cornerRadius(12)
            
            Rectangle()
                .fill(Color.black.opacity(0.3))
                .frame(width: 140, height: 180)
                .cornerRadius(12)

            Text(title)
                .fontWeight(.semibold)
                .padding([.leading, .bottom], 8)
                .foregroundColor(.white)
        }
    }
}

// #Preview is useful for Xcode previews
#Preview {
    HomePageView()
}
