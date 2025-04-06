//
//  GearItemView.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//

import SwiftUI

struct GearItemView: View {
    let gearItem: GearItem
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var dbService = DBService.shared

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Image Placeholder
                Image("ceriumjacket") // Replace with actual image asset name
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 240)
                    .clipped()
                    .cornerRadius(10)

                // Title & Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(gearItem.name.uppercased())
                        .font(.title)
                        .bold()
                    Text("Size: Medium  •  Color: Interstellar")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }

                Divider()

                // User Info
                HStack {
                    Image(systemName: "person.crop.circle.fill") // Placeholder avatar
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.gray)
                    VStack(alignment: .leading) {
                        Text((dbService.user?.firstName.rawValue)!)
                            .font(.headline)
                        Text("0.8 km Away")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                // Condition
                VStack(alignment: .leading) {
                    Text("Current Condition:")
                        .font(.subheadline)
                        .bold()
                    Text(gearItem.currentCondition.rawValue)
                        .font(.subheadline)
                }

                // Reserve Button
                Button(action: {
                    print("Reserved!")
                }) {
                    Text("RESERVE")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Gear Details")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    GearItemView(gearItem: GearItem(
        id: 1,
//        createdAt: Date(),
        name: "Cerium Jacket",
        type: .jacket,
        description: "A lightweight down jacket perfect for alpine adventures.",
        currentCondition: .excellent,
        latitude: 49.2827,
        longitude: -123.1207,
        isAvailable: true
    ))
}
