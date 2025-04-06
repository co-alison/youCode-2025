//
//  EmptyImage.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-06.
//

import SwiftUI

struct EmptyImage: View {
    var body: some View {
        Rectangle()
            .fill(Color.accent)
            .frame(width: 100, height: 100)
            .cornerRadius(8)
    }
}
