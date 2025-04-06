//
//  AddGearView.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//

import SwiftUI
import PhotosUI

struct AddGearView: View {
    @StateObject private var nfcService = NFCService()
    @ObservedObject private var dbService = DBService.shared
    var gear_id: Int?
    @State private var isPerformingTask = false
    
    @State private var name: String = ""
    @State private var createdAt: Date?
    @State private var type: GearItem.GearType = GearItem.GearType.backpack
    @State private var description: String = ""
    @State private var currentCondition: GearItem.GearCondition = GearItem.GearCondition.excellent
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    @State private var isAvailable = true
    @State private var selectedImage: PhotosPickerItem?
    @State private var gearUIImage: UIImage?

    var body: some View {
        VStack {
            if let gearUIImage = gearUIImage {
                Image(uiImage: gearUIImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                    .cornerRadius(10)
                    .padding()
            }
            
            PhotosPicker("Select Gear Photo", selection:
                $selectedImage, matching: .images)
                .padding()
                .onChange(of: selectedImage) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let image = UIImage(data: data) {
                            gearUIImage = image
                        }
                    }
                }
            
            TextField("Gear Name: ex. Blundstone boots", text: $name)
            TextField("Gear Description: ex. Size 4.5, Black", text: $description)
            Picker("Gear Type", selection: $type) {
                ForEach(GearItem.GearType.allCases, id: \.self) { gearType in
                    Text(gearType.rawValue.capitalized)
                }
            }
//            .pickerStyle(.menu)
            Picker("Gear Condition", selection: $currentCondition) {
                ForEach(GearItem.GearCondition.allCases, id: \.self) { gearCondition in
                    Text(gearCondition.rawValue.capitalized)
                }
            }
            
            Button(
                action: {
                isPerformingTask = true
                Task {
                    let result = try await dbService.createGear(name: name, type: type, description: description, currentCondition: currentCondition, latitude: 0.0, longitude: 0.0, isAvailable: isAvailable, gearUIImage: gearUIImage)
                    guard let id = result.id else {
                        print("Error finding newly-added Gear ID")
                        return
                    }
                    nfcService.startWriting(with: String(id))
                    print("Added Gear \(String(id))")
                    isPerformingTask = false
                }
            },
                label: {
                    if isPerformingTask {
                        ProgressView()
                    } else {
                        Text("Scan Tag to Add Gear")
                    }
                }
            )
            .disabled(isPerformingTask)
        }
    }
}

#Preview {
    BorrowView()
}
