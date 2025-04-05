//
//  ReadTagView.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//

import SwiftUI

struct ReadTagView: View {
    @StateObject private var nfcService = NFCService()

    var body: some View {
        VStack(spacing: 24) {
            Text("NFC Tag Reader")
                .font(.title)
                .bold()

            HStack(spacing: 20) {
                Button("Read Tag") {
                    nfcService.startReading()
                }
                .buttonStyle(.borderedProminent)

            }

            if !nfcService.scannedText.isEmpty {
                VStack(alignment: .leading) {
                    Text("Scanned Text:")
                        .font(.headline)
                    Text(nfcService.scannedText)
                        .padding(.top, 4)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }

            if !nfcService.statusMessage.isEmpty {
                Text(nfcService.statusMessage)
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
