//
//  MapView.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//

import SwiftUI
import MapKit

struct MapView: View {
    let gearItems: [GearItem]
    
    @State var region: MKCoordinateRegion
    
    @State private var selectedGearItem: GearItem? = nil
    @State private var reservedGearItem: GearItem? = nil
    
    var body: some View {
        NavigationStack {
            Map(coordinateRegion: $region, annotationItems: gearItems) { item in
                MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)) {
                    Button(action: {
                        selectedGearItem = item
//                        showGearItemView = true
                    }) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                            .font(.title)
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
}

#Preview {
//    MapView()
}
