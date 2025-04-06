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
    
//    private var status: Status

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {

                NavigationLink(destination: BorrowView()) {
                    Text("Borrow Gear")
                }

                NavigationLink(destination: ReturnView()) {
                    Text("Return Gear")
                }
                
//                NavigationLink(destination: AddGearView()) {
//                    Text("Add Gear Tag")
//                }
                               
            }
            .navigationTitle("Scan a Tag")
        }
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
    ReadTagView()
}
