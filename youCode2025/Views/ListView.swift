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
    @State private var reservedGearItem: GearItem? = nil
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(gearItems) { gearItem in
                    Button {
                        selectedGearItem = gearItem
                    } label: {
                        HStack {
                            ZStack {
                                if let urlString = gearItem.gearPhotoURL,
                                   let imageURL = URL(string: urlString) {
                                    AsyncImage(url: imageURL) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 100)
                                            .clipped()
                                            .cornerRadius(10)
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 100, height: 100)
                                    }
                                } else {
                                    EmptyImage(width: 100, height: 100)
                                }
                            }
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
            GearItemView(gearItem: gear,
                         onReserve: {
                            reservedGearItem = gear
                            selectedGearItem = nil
                        }
            )
        }
        .sheet(item: $reservedGearItem) { gear in
            ContactInfoView(gearItem: gear)
        }
    }
}

#Preview {
//    ListView()
}
