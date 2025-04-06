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
    
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 49.2827, longitude: -123.1207), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    @State private var selectedGearItem: GearItem? = nil
//    @State private var showGearItemView: Bool = false
    
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
//            .edgesIgnoringSafeArea(.all)
            .sheet(item: $selectedGearItem) { gear in
                GearItemView(gearItem: gear)
            }
        }
    }
}

#Preview {
//    MapView()
}
