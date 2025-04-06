//
//  EmptyImage.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-06.
//

import SwiftUI

struct EmptyImage: View {
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        Rectangle()
            .fill(Color.accent)
            .frame(width: width, height: height)
            .cornerRadius(8)
    }
}
