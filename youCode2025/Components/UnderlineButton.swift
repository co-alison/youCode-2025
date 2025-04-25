//
//  UnderlineButton.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-06.
//
import SwiftUI
struct UnderlineButton: View {
    var text: String
    var width: CGFloat?
    var height: CGFloat?
    var alignment: Alignment?
    var action : () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .underline()
                .foregroundColor(.white)
                .font(.title2)
                .padding()
                .frame(width: 150, height: 40)
                .background(Color.black)
                .cornerRadius(10)
        }.frame(width: width ?? nil, height: height ?? nil, alignment: alignment ?? .center)
    }
}

