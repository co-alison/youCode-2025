//
//  ReadTagView.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//

import SwiftUI

struct ReadTagView: View {
    @StateObject private var nfcService = NFCService()
    @ObservedObject private var dbService = DBService.shared
    private var status: Status

    var body: some View {
        VStack(spacing: 24) {
            Text("Scan a Tag")
                .font(.title)
                .bold()
            
            
            switch status {
            case .borrowing:
                Button("Confirm Transfer") {
                    dbService.associateGearWithUser(userId: dbService.user?.id, gearId: <#T##Int#>)
                }
                Button("Cancel Transfer") {
                    
                }
            case .returning:
                
            case .adding:
                
                
            }
                .onAppear(nfcService.startReading())
        

            

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

extension ReadTagView {
    enum Status {
        case idle
        case borrowing
        case returning
        case adding
    }
}

#Preview {
    ContentView()
}
