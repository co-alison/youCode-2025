//
//  BorrowView.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//
import SwiftUI

struct BorrowView: View {
    @EnvironmentObject var nfcService: NFCService
//    @StateObject private var nfcService = NFCService()
//    @StateObject private var scannedText
    @ObservedObject private var dbService = DBService.shared
    var gear_id: Int?
    @State private var isPerformingTask = false
    @State private var gearIsCurrentlyBorrowed = false
    @State private var tagAdded = false

    var body: some View {
        VStack {
            if gearIsCurrentlyBorrowed {
                Text("This piece of gear is already borrowed. Try scanning another item.")
                Button("OK") {
                    gearIsCurrentlyBorrowed = false
                    nfcService.scannedText = ""
                }
            } else {
                if (nfcService.scannedText.isEmpty) {
                    Button("Scan Tag to Borrow Item") {
                        nfcService.startReading()
                    }
                } else {
                    Button(
                        action: {
                            isPerformingTask = true
                            Task {
                                do {
                                    print("userid: \(dbService.user!.id)")
                                    print("scanned text: \(nfcService.scannedText)")
                                    let x = try await dbService.associateGearWithUser(userId: dbService.user!.id, gearId: Int(nfcService.scannedText)!)
                                    let y = try await dbService.updateGear(id: Int(nfcService.scannedText)!, isAvailable: false)
                                    isPerformingTask = false
                                    nfcService.scannedText = ""
                                } catch let error as NSError {
                                    if error.domain == "AppError" && error.code == 1001 {
                                        DispatchQueue.main.async {
                                            isPerformingTask = false
                                            gearIsCurrentlyBorrowed = true
                                        }
                                        return
                                    }
                                }
                            }
                            print(nfcService.scannedText)
                        
                    },
                        label: {
                            if isPerformingTask {
                                ProgressView()
                            } else {
                                Text("Confirm Borrow")
                            }
                        }
                    )
                    .disabled(isPerformingTask)
                    
                    Button("Cancel Borrow") {
                        print("Cancelled")
                    }
                }
            }
            
        }
        
    }
}

#Preview {
    BorrowView()
}
