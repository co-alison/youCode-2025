//
//  ScanView.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//

import SwiftUI

struct ScanView: View {
    @StateObject private var nfcReadService = NFCReadService()
    @StateObject private var nfcWriteService = NFCWriteService()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("NFC Tag Reader/Writer")
                .font(.title)
                .padding()
            
            Button("Scan NFC Tag") {
                nfcReadService.scanTag()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Write NFC Tag") {
                let sampleData = GearItem(id: UUID().uuidString, gearType: GearType.boots, latitude: 49.282729, longitude: -123.120738, name: "Grouse Grind", description: "Start of the trail")
                nfcWriteService.writeTag(data: sampleData)
            }.buttonStyle(.borderedProminent)
            
//            Text(nfcService.message)
//                .padding()
        }
    }
}

#Preview {
    ContentView()
}
