//
//  ContentView.swift
//  youCode2025
//
//  Created by Cindy Cui on 2025-04-05.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject private var dbService = DBService.shared
    var body: some View {
        if dbService.user != nil {
            HomePageView()
        } else {
            WelcomeView()
        }
    }
}

#Preview {
    ContentView()
}
