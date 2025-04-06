//
//  BorrowView.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//
import SwiftUI

struct BorrowView: View {
//    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var nfcService: NFCService
    @ObservedObject private var dbService = DBService.shared
    @Binding var userNeedsRefresh: Bool

    var gear_id: Int?
    @State private var isPerformingTask = false
    @State private var gearIsCurrentlyBorrowed = false
    @State private var name = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            if gearIsCurrentlyBorrowed {
                VStack(spacing: 16) {
                    Text("⚠️ This piece of gear is already borrowed.")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding()

                    Button(action: {
                        gearIsCurrentlyBorrowed = false
                        nfcService.scannedText = ""
                    }) {
                        Text("OK")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else if nfcService.scannedText.isEmpty {
                VStack(spacing: 16) {
                    Text("Ready to borrow gear?")
                        .font(.title2)
                        .bold()

                    Button(action: {
                        nfcService.startReading()
                    }) {
                        Text("Scan Tag to Borrow Item")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
            } else {
                VStack(spacing: 16) {
                    Button(action: {
                        isPerformingTask = true
                        Task {
                            do {
                                guard let userId = dbService.user?.id,
                                      let scannedId = Int(nfcService.scannedText) else { return }

                                _ = try await dbService.associateGearWithUser(userId: userId, gearId: scannedId)
                                _ = try await dbService.updateGear(id: scannedId, isAvailable: false)
                                
                                userNeedsRefresh = true
                                isPerformingTask = false
                                nfcService.scannedText = ""
                            } catch let error as NSError {
                                if error.domain == "AppError" && error.code == 1001 {
                                    DispatchQueue.main.async {
                                        isPerformingTask = false
                                        gearIsCurrentlyBorrowed = true
//                                        dismiss()
                                    }
                                }
                            }
                        }
                    }) {
                        if isPerformingTask {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Confirm Borrow")
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .disabled(isPerformingTask)

                    Button(action: {
                        nfcService.scannedText = ""
                    }) {
                        Text("Cancel Borrow")
                            .foregroundColor(.red)
                    }
                }
            }
                
        }
        .padding()
    }
}

#Preview {
//    BorrowView()
//        .environmentObject(NFCService())
}
