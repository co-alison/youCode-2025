//
//  ReadTagView.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//


import SwiftUI

struct ReadTagView: View {
    @StateObject var nfcService = NFCService()
    @ObservedObject private var dbService = DBService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {

                // Borrow Gear Button
                NavigationLink(destination: BorrowView().environmentObject(nfcService)) {
                    Text("Borrow Gear")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Return Gear Button
                NavigationLink(destination: ReturnView().environmentObject(nfcService)) {
                    Text("Return Gear")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Add Gear Tag Button
                NavigationLink(destination: AddGearView()) {
                    Text("Add Gear Tag")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

            }
            .navigationTitle("Scan a Tag")
            .padding()
        }
    }
}

#Preview {
    ReadTagView()
}
