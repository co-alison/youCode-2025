//
//  GearsView.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//

import SwiftUI
import MapKit

struct GearsView: View {
    @StateObject private var locationManager = LocationService()
    @State private var showingMap = false
    var gearItems: [GearItem]
    var gearType: String
    
    var body: some View {
        NavigationStack {
            Group {
                if showingMap {
                    MapView(gearItems: gearItems, region: MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locationManager.latitude, longitude: locationManager.longitude), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)) )
                } else {
                    ListView(gearItems: gearItems)
                }
            }
            .navigationTitle(gearType.capitalized)
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
        .onAppear {
            locationManager.requestLocationPermission()
            locationManager.startUpdatingLocation()
        }
    }
}

#Preview {
//    GearsView()
}
