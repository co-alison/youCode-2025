//
//  ReturnView.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//

import SwiftUI
import PhotosUI

struct ReturnView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var nfcService: NFCService
    @ObservedObject private var dbService = DBService.shared
    @StateObject private var locationManager = LocationService()
    
    @State private var isPerformingTask = false
    @State private var selectedCondition: GearItem.GearCondition?
    @State private var locationText: String = ""
    
    @State private var gearUIImage: UIImage?
    @State private var selectedImage: PhotosPickerItem?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("SCAN TAG TO RETURN ITEM")
                    .font(.headline)
                    .padding(.horizontal)
                
                if nfcService.scannedText.isEmpty {
                    Button(action: {
                        nfcService.startReading()
                    }) {
                        Text("Scan Tag")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                } else {
                    SectionHeader(title: "REPORT CONDITION")
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 8) {
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
                    
//                    Text("UPLOAD IMAGE & LOCATION")
//                        .font(.headline)
//                        .padding(.horizontal)
//                    
//                    Text("Share a picture of where you took this piece!")
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .padding(.bottom, 5)
//                        .padding(.horizontal)
//                    
//                    HStack {
//                        HStack {
//                            Image(systemName: "mappin.circle.fill")
//                                .foregroundColor(.gray)
//                            
//                            TextField("Where was this photo taken?", text: $locationText)
//                                .padding(.vertical, 8)
//                        }
//                        .padding(.horizontal)
//                        .background(Color(UIColor.systemGray5))
//                        .cornerRadius(8)
//                        
//                        Button(action: {
//                        }) {
//                            Image(systemName: "arrow.up.square.fill")
//                                .font(.title)
//                                .foregroundColor(Color.yellow)
//                        }
//                        .padding(.horizontal, 8)
//                    }
//                    .padding(.horizontal)
                    
                    SectionHeader(title: "UPLOAD ITEM PHOTO")
                    VStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                            .foregroundColor(.gray)
                            .frame(height: 180)
                            .overlay(
                                Group {
                                    if let gearUIImage = gearUIImage {
                                        Image(uiImage: gearUIImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity)
                                    } else {
                                        Image(systemName: "arrow.up.to.line.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(.gray)
                                    }
                                }
                            )

                        PhotosPicker("Choose a photo", selection: $selectedImage, matching: .images)
                            .frame(width: 180, height: 180)
                            .contentShape(Rectangle())
                            .onChange(of: selectedImage) { newItem in
                                Task {
                                    if let item = newItem {
                                        if let data = try? await item.loadTransferable(type: Data.self),
                                           let image = UIImage(data: data) {
                                            gearUIImage = image
                                        }
                                    }
                                }
                        }
                    }
    
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
                    
                    Button(action: {
                        isPerformingTask = true
                        Task {
                            guard let gearId = Int(nfcService.scannedText),
                                  let condition = selectedCondition?.rawValue,
                                  let userId = dbService.user?.id else {
                                isPerformingTask = false
                                return
                            }
                            
                            do {
                                try await dbService.updateGearUser(userId: userId, gearId: gearId, isActive: false)
                                try await dbService.updateGear(
                                    id: gearId,
                                    currentCondition: condition,
                                    latitude: locationManager.latitude,
                                    longitude: locationManager.longitude,
                                    isAvailable: true,
                                    gearUIImage: gearUIImage
                                )
                                let _ = try await dbService.updateProfile(id: dbService.user!.id, points: (dbService.user?.points! ?? 0) + 1)
                                
                                nfcService.scannedText = ""
                                selectedCondition = nil
                                locationText = ""
                                isPerformingTask = false
                            } catch {
                                print("Error updating gear: \(error)")
                            }
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
        .padding(.bottom)
        .navigationTitle("Return Item")
        .onAppear {
            locationManager.requestLocationPermission()
            locationManager.startUpdatingLocation()
            selectedCondition = nil
            locationText = ""
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
        }
    }
}

#Preview {
    NavigationView {
        ReturnView()
            .environmentObject(NFCService())
    }
}
