//
//  HomePageView.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-05.
//

import SwiftUI

struct HomePageView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search Gear...", text: .constant(""))
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Browse Categories
                    Text("Browse Categories")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            CategoryCard(title: "Jackets", imageName: "jacket")
                            CategoryCard(title: "", imageName: "ski") // Replace with real title
                            CategoryCard(title: "", imageName: "camping") // Replace with real title
                        }
                        .padding(.horizontal)
                    }
                    
                    // Challenge of the Month
                    Button(action: {}) {
                        Text("Challenge of the month")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }
                    
                    Divider()
                    
                    // Nearby Gear
                    Text("Nearby Gear")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        ForEach(0..<2) { _ in
                            GearItemView()
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
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

struct GearItemView: View {
    var body: some View {
        HStack {
            Image(systemName: "backpack")
                .resizable()
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Ion Light Weight Chalk Bag")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("0.8 km away • Available Now")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 40, height: 20)
                .foregroundColor(.black)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    HomePageView()
}
