//
//  GearsView.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//

import SwiftUI

struct GearsView: View {
    @State private var showingMap = false
    
    let gearItems: [GearItem] = [GearItem(id: "123", gearType: GearType.boots, latitude: 49.28332506862739, longitude: -123.13560646901378, name: "Atom Hoodie", description: "jacket")] // TODO
    var body: some View {
        NavigationStack {
            Group {
                if showingMap {
                    MapView(gearItems: gearItems)
                } else {
                    ListView(gearItems: gearItems)
                }
            }
            .navigationTitle("Gear")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        showingMap.toggle()
                    }) {
                        Image(systemName: showingMap ? "list.bullet" : "map")
                    }
                }
            }
        }
    }
}

#Preview {
    GearsView()
}
