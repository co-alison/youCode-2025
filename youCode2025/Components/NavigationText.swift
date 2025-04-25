//
//  NavigationText.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-06.
//
import SwiftUI
struct NavigationText: View {
    var text: String
    var body: some View {
        Text(text)
            .underline()
            .foregroundColor(.white)
            .font(.title2)
            .padding()
            .frame(width: 200)
            .background(Color.black)
            .cornerRadius(10)
    }
}
