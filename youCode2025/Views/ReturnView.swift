//
//  ReturnView.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//

import SwiftUI

struct ReturnView: View {
    @EnvironmentObject var nfcService: NFCService
    @ObservedObject private var dbService = DBService.shared
    @StateObject private var locationManager = LocationService()
    
    @State private var isPerformingTask = false
    @State private var selectedCondition: GearItem.GearCondition?
    @State private var locationText: String = ""
    // For testing purposes
    @State private var hasScanned = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Section: Scan Tag Button
                Text("SCAN TAG TO RETURN ITEM")
                    .font(.headline)
                    .padding(.horizontal)
                
                // Force view to show both states for testing
                if nfcService.scannedText.isEmpty && !hasScanned {
                    Button(action: {
                        nfcService.startReading()
                        // For testing purposes - remove this in production
                        // and rely solely on nfcService.scannedText
                        hasScanned = true
                        // Simulate scan for testing
                        nfcService.scannedText = "12345"
                    }) {
                        Text("Scan Tag")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                
                // Show these sections after scanning
                if !nfcService.scannedText.isEmpty || hasScanned {
                    // Section: Report Condition
                    Text("REPORT CONDITION")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    HStack(spacing: 8) {
                        // Access the actual case values from your GearItem.GearCondition enum
                        // Using the correct case names from your actual implementation
                        ForEach(GearItem.GearCondition.allCases, id: \.self) { condition in
                            Button(action: {
                                selectedCondition = condition
                            }) {
                                Text(condition.rawValue.capitalized)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(selectedCondition == condition ? Color.black : Color(.systemGray5))
                                    .foregroundColor(selectedCondition == condition ? .white : .black)
                                    .cornerRadius(10)
                                    .font(.subheadline)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Section: Upload Image & Location
                    Text("UPLOAD IMAGE & LOCATION")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Text("Share a picture of where you took this piece!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 5)
                        .padding(.horizontal)
                    
                    HStack {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.gray)
                            
                            TextField("Where was this photo taken?", text: $locationText)
                                .padding(.vertical, 8)
                        }
                        .padding(.horizontal)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(8)
                        
                        Button(action: {
                            // Image upload logic
                        }) {
                            Image(systemName: "arrow.up.square.fill")
                                .font(.title)
                                .foregroundColor(Color.yellow)
                        }
                        .padding(.horizontal, 8)
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading) {
                        Text("For damage affecting usage contact")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        Text("arc1tag_services@gmail.com")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    Spacer().frame(height: 24)
                    
                    // Section: Complete Return Button
                    Button(action: {
                        isPerformingTask = true
                        Task {
                            guard let gearId = Int(nfcService.scannedText.isEmpty ? "12345" : nfcService.scannedText),
                                  let condition = selectedCondition?.rawValue,
                                  let userId = dbService.user?.id else {
                                isPerformingTask = false
                                return
                            }
                            
                            // Replace with actual location-fetching if needed
                            let mockLat = 51.0447
                            let mockLong = -114.0719
                            
<<<<<<< Updated upstream
                            try await dbService.updateGearUser(userId: userId, gearId: gearId, isActive: false)
                            try await dbService.updateGear(
                                id: gearId,
                                currentCondition: condition,
                                latitude: locationManager.latitude,
                                longitude: locationManager.longitude,
                                isAvailable: true
                            )
=======
                            do {
                                try await dbService.updateGearUser(userId: userId, gearId: gearId, isActive: false)
                                try await dbService.updateGear(
                                    id: gearId,
                                    currentCondition: condition,
                                    latitude: mockLat,
                                    longitude: mockLong,
                                    isAvailable: true
                                )
                                
                                // Reset state
                                hasScanned = false
                                nfcService.scannedText = ""
                                selectedCondition = nil
                                locationText = ""
                            } catch {
                                print("Error updating gear: \(error)")
                            }
>>>>>>> Stashed changes
                            
                            isPerformingTask = false
                        }
                    }) {
                        if isPerformingTask {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        } else {
                            Text("COMPLETE RETURN")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedCondition == nil ? Color.gray : Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    .disabled(isPerformingTask || selectedCondition == nil)
                }
            }
            .padding(.vertical)
        }
<<<<<<< Updated upstream
        .padding(.bottom)
        .onAppear {
            locationManager.requestLocationPermission()
            locationManager.startUpdatingLocation()
        }
    }
}

struct ConditionButton: View {
    let condition: GearItem.GearCondition
    let isSelected: Bool
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(condition.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity)
                
                Text(description)
                    .font(.system(size: 10))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .frame(height: 30)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 2)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.black : Color.gray, lineWidth: isSelected ? 2 : 1)
                    .background(isSelected ? Color.gray.opacity(0.2) : Color.white)
                    .cornerRadius(8)
            )
=======
        .navigationTitle("Return Item")
        .onAppear {
            // Reset state when view appears
            selectedCondition = nil
            locationText = ""
>>>>>>> Stashed changes
        }
    }
}

#Preview {
    NavigationView {
        ReturnView()
            .environmentObject(NFCService())
    }
}
