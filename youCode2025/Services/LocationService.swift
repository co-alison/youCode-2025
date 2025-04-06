//
//  LocationService.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-06.
//

import SwiftUI
import CoreLocation

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    
    @Published var latitude: Double = 49.2827
    @Published var longitude: Double = -123.1207
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    // Request location permission
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    // Start updating location
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    // Stop updating location
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    // CLLocationManagerDelegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
        }
    }
    
    // Handle location errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
    }
}

