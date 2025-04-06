//
//  ReturnView.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//

import SwiftUI

struct ReturnView: View {
    @StateObject private var nfcService = NFCService()
    @ObservedObject private var dbService = DBService.shared
    @State private var isPerformingTask = false
    @State private var selectedCondition: GearItem.GearCondition?
    @State private var locationText: String = ""
    @State private var latitude: Double?
    @State private var longitude: Double?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("REPORT CONDITION")
                .font(.headline)
                .padding(.top)
            
            HStack(spacing: 8) {
                ConditionButton(
                    condition: .poor,
                    isSelected: selectedCondition == .poor,
                    description: "Significant damage that does not affect usage.",
                    action: { selectedCondition = .poor }
                )
                ConditionButton(
                    condition: .fair,
                    isSelected: selectedCondition == .fair,
                    description: "Weathered, but usable.",
                    action: { selectedCondition = .fair }
                )
                ConditionButton(
                    condition: .good,
                    isSelected: selectedCondition == .good,
                    description: "No issues here.",
                    action: { selectedCondition = .good }
                )
                ConditionButton(
                    condition: .excellent,
                    isSelected: selectedCondition == .excellent,
                    description: "Practically new!",
                    action: { selectedCondition = .excellent }
                )
            }
            .padding(.horizontal)
            
            Divider().padding(.vertical)
            
            Text("UPLOAD IMAGE & LOCATION")
                .font(.headline)
            
            Text("Share a picture of where you took this piece!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 5)
            
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
            
            Text("For damage affecting usage contact")
                .font(.footnote)
                .foregroundColor(.secondary)
            Text("arc1tag_services@gmail.com")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Spacer()
            
            if nfcService.scannedText.isEmpty {
                Button(action: {
                    nfcService.startReading()
                }) {
                    Text("Scan Tag to Return Item")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .disabled(selectedCondition == nil)
            } else {
                Button(
                    action: {
                        isPerformingTask = true
                        Task {
                            guard let gearId = Int(nfcService.scannedText),
                                  let condition = selectedCondition?.rawValue,
                                  let userId = dbService.user?.id else { return }
                            
                            // Replace with actual location-fetching if needed
                            let mockLat = 51.0447
                            let mockLong = -114.0719
                            
                            try await dbService.disassociateGearFromUser(userId: userId, gearId: gearId)
                            try await dbService.updateGear(
                                id: gearId,
                                currentCondition: condition,
                                latitude: mockLat,
                                longitude: mockLong,
                                isAvailable: true
                            )
                            
                            isPerformingTask = false
                        }
                    },
                    label: {
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
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                )
                .padding(.horizontal)
                .disabled(isPerformingTask || selectedCondition == nil)
            }
        }
        .padding(.bottom)
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
        }
    }
}

#Preview {
    ReturnView()
}
