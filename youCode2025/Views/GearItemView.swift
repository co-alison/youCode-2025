//
//  GearItemView.swift
//  youCode2025
//
//  Created by Alison Co on 2025-04-05.
//

import SwiftUI

struct GearItemView: View {
    let gearItem: GearItem
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Text("Hello World")
            Image(systemName: "gear")
            
            Text("Name: \(gearItem.name)")
            VStack {
                Text("Description")
                Text(gearItem.description)
            }
            
            VStack {
                Text("Conditions")
//                Text(gearItem.conditions)
            }
            Text("User")
        }
        .navigationTitle("Gear Details")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
//    GearItemView()
}
