//
//  GearRepository.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-05.
//

import Foundation

class GearRepository {
    private let supabase: SupabaseClient2
    
    init(supabase: SupabaseClient2) {
        self.supabase = supabase
    }
    
    // Get a user and all their gear
    func getUserWithGear(userId: UUID) async throws -> (UserItem, [GearItem]) {
        // Get the user
        let user = try await supabase.getUser(id: userId)
        
        // Get all gear associated with the user
        let userGears = try await supabase.getUserGear(userId: userId)
        let gear = userGears.compactMap { $0.gear }
        
        return (user, gear)
    }
    
    // Add a gear item to a user
    func addGearToUser(userId: UUID, gear: GearItem) async throws {
        _ = try await supabase.associateGearWithUser(userId: userId, gearId: gear.id)
    }
    
    // Find gear near a location
    func getGearWithinRadius(latitude: Double, longitude: Double, radiusInKm: Double) async throws -> [GearItem] {
        let allGear = try await supabase.getAllGear()
        
        return allGear.filter { gear in
            let distance = calculateDistance(
                lat1: latitude, lon1: longitude,
                lat2: gear.latitude, lon2: gear.longitude
            )
            return distance <= radiusInKm
        }
    }
    
    // Helper to calculate distance between locations
    private func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371.0 // Earth radius in kilometers
        
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        
        let a = sin(dLat/2) * sin(dLat/2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                sin(dLon/2) * sin(dLon/2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        return R * c
    }
}
