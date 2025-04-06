//
//  BorrowView.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//
import SwiftUI

struct BorrowView: View {
    @ObservedObject private var dbService = DBService.shared
    @Environment(\.dismiss) var dismiss
    var gear_id: Int?

    var body: some View {
        NavigationStack {
            Button("Confirm Borrow") {
                
            }
        }
        .navigationTitle("Borrow Gear")
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                XMarkButton().onTapGesture {
                    dismiss()
                }
            }
        })
        
    }
}
