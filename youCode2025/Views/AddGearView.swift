//
//  AddGearView.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//

import SwiftUI
import PhotosUI

struct AddGearView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var nfcService = NFCService()
    @StateObject private var locationManager = LocationService()
    @ObservedObject private var dbService = DBService.shared
    
    var gear_id: Int?
    
    @State private var isPerformingTask = false
    @State private var name: String = ""
    @State private var createdAt: Date?
    @State private var type: GearItem.GearType = .backpack
    @State private var description: String = ""
    @State private var currentCondition: GearItem.GearCondition = .excellent
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    @State private var isAvailable = true
    @State private var selectedImage: PhotosPickerItem?
    @State private var gearUIImage: UIImage?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // Section: Upload Photo
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
                                if let data = try? await newItem?.loadTransferable(type: Data.self),
                                   let image = UIImage(data: data) {
                                    gearUIImage = image
                                }
                            }
                        }
                }

                // Section: Item Info
                SectionHeader(title: "INPUT ITEM INFORMATION")
                VStack(spacing: 12) {
                    TextField("Item Name", text: $name)
                        .textFieldStyle(.roundedBorder)

                    TextField("Color Name", text: $description)
                        .textFieldStyle(.roundedBorder)

                    Picker("Category", selection: $type) {
                        ForEach(GearItem.GearType.allCases, id: \.self) {
                            Text($0.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.menu)

                }

                // Section: Report Condition
                SectionHeader(title: "REPORT CONDITION")
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    ForEach(GearItem.GearCondition.allCases, id: \.self) { condition in
                        Button(action: {
                            currentCondition = condition
                        }) {
                            Text(condition.rawValue.capitalized)
                                .padding(.vertical, 12)
                                .frame(maxWidth: .infinity)
                                .background(currentCondition == condition ? Color.black : Color(.systemGray5))
                                .foregroundColor(currentCondition == condition ? .white : .black)
                                .cornerRadius(10)
                                .font(.subheadline)
                        }
                    }
                }
            
            Button(
                action: {
                    isPerformingTask = true
                    Task {
                        let result = try await dbService.createGear(name: name, type: type, description: description, currentCondition: currentCondition, latitude: locationManager.latitude, longitude: locationManager.longitude, isAvailable: isAvailable, gearUIImage: gearUIImage)
                        
                        let _ = try await dbService.updateProfile(id: dbService.user!.id, points: (dbService.user?.points! ?? 0) + 2)
                        
                        guard let id = result.id else {
                            print("Error finding newly-added Gear ID")
                            return
                        }
                        
                        nfcService.startWriting(with: String(id))
                        print("Added Gear \(id)")
                        isPerformingTask = false
                        dismiss()
                    }
                }) {
                    if isPerformingTask {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("ADD TO POOL")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .disabled(isPerformingTask)
            }
            .padding()
        }
        .onAppear {
            locationManager.requestLocationPermission()
            locationManager.startUpdatingLocation()
        }
    }
}

struct SectionHeader: View {
    var title: String
    var body: some View {
        Text(title)
            .font(.headline)
            .padding(.bottom, 4)
            .overlay(Divider(), alignment: .bottom)
    }
}

#Preview {
    AddGearView()
}
