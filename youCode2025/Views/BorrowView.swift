//
//  BorrowView.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//
import SwiftUI

struct BorrowView: View {
    @StateObject private var nfcService = NFCService()
    @ObservedObject private var dbService = DBService.shared
//    @Environment(\.dismiss) var dismiss
    var gear_id: Int?
    @State private var isPerformingTask = false

    var body: some View {
        VStack {
            if (nfcService.scannedText.isEmpty) {
                Button("Scan Tag") {
                    nfcService.startReading()
                }
            } else {
                Button(
                    action: {
                    isPerformingTask = true
                    Task {
                        try await dbService.associateGearWithUser(userId: dbService.user!.id, gearId: Int(nfcService.scannedText)!)
                        isPerformingTask = false
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
//        .navigationTitle("Borrow Gear")
//        .toolbar(content: {
//            ToolbarItem(placement: .navigationBarLeading) {
//                XMarkButton().onTapGesture {
//                    dismiss()
//                }
//            }
//        })
        
    }
}

#Preview {
    BorrowView()
}
