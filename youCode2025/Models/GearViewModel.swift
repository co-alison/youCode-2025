//
//  GearViewModel.swift
//  youCode2025
//
//  Created by Anisa Pirani on 2025-04-05.
//

import SwiftUI
import Combine

class GearViewModel: ObservableObject {
    private let repository: GearRepository
    @Published var userGear: [GearItem] = []
    @Published var nearbyGear: [GearItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init(repository: GearRepository) {
        self.repository = repository
    }
    
    // Load all gear for a user
    func loadUserGear(userId: UUID) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let (_, gear) = try await repository.getUserWithGear(userId: userId)
                
                await MainActor.run {
                    self.userGear = gear
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    // Load gear near a location
    func loadNearbyGear(latitude: Double, longitude: Double, radiusInKm: Double = 10.0) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let gear = try await repository.getGearWithinRadius(
                    latitude: latitude,
                    longitude: longitude,
                    radiusInKm: radiusInKm
                )
                
                await MainActor.run {
                    self.nearbyGear = gear
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
}
