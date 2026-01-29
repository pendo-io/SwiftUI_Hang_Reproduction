//
//  ContentView.swift
//  Rumble_Hang
//
//  Created by Michael Rozenblat on 27/01/2026.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
//        MainTabView()
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                
                NavigationLink("Show Nested LazyVStack Page") {
                    NestedLazyVStackView()
                }
                .padding(.top, 12)
            }
            .padding()
            .navigationTitle("Rumble Hang Test")
        }
    }
}

#Preview {
    ContentView()
}
