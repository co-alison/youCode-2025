//
//  ListView.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//

import SwiftUI

struct ListView: View {
    let gearItems: [GearItem]
    
    @State private var selectedGearItem: GearItem? = nil
//    @State private var showGearItemView: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(gearItems) { gearItem in
                    Button {
                        selectedGearItem = gearItem
//                        showGearItemView = true
                    } label: {
                        HStack {
                            ZStack {
                                if let urlString = gearItem.gearPhotoURL,
                                   let imageURL = URL(string: urlString) {
                                    AsyncImage(url: imageURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 240, height: 240)
                                            .clipped()
                                            .cornerRadius(10)
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 240, height: 240)
                                    }
                                } else {
                                    Image("ceriumjacket") // placeholder
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 240, height: 240)
                                        .clipped()
                                        .cornerRadius(10)
                                }
                            }
                            Image(systemName: "gear")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipped()
                                .cornerRadius(10)
                            Text(gearItem.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .padding(.leading, 8)
                        }
                        .padding()
                    }
                }
            }
        }
        .sheet(item: $selectedGearItem) { gear in
            GearItemView(gearItem: gear)
        }
    }
}

#Preview {
//    ListView()
}
