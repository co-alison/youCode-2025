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
    var gear_id: Int?
    @State private var isPerformingTask = false

    var body: some View {
        VStack {
            if (nfcService.scannedText.isEmpty) {
                Button("Scan Tag to Return Item") {
                    nfcService.startReading()
                }
            } else {
                Button(
                    action: {
                    isPerformingTask = true
                    Task {
                        try await dbService.disassociateGearFromUser(userId: dbService.user!.id, gearId: Int(nfcService.scannedText)!)
                        try await dbService.updateGear(id: Int(nfcService.scannedText)!, isAvailable: true)
                        isPerformingTask = false
                    }
                    print(nfcService.scannedText)
                    
                },
                    label: {
                        if isPerformingTask {
                            ProgressView()
                        } else {
                            Text("Confirm Return")
                        }
                    }
                )
                .disabled(isPerformingTask)
                
                Button("Cancel Return") {
                    print("Cancelled")
                }
            }
        }
        
    }
}

#Preview {
    BorrowView()
}
