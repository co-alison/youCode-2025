//
//  WriteTagView.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//

import SwiftUI

struct WriteTagView: View {
    @StateObject private var nfcService = NFCService()
    @State private var textToWrite: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("NFC Tag Writer")
                .font(.title)
                .bold()

            TextField("Text to write to tag", text: $textToWrite)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)


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
