//
//  MainTabView.swift
//  Rumble_Hang
//
//  Created by Michael Rozenblat on 27/01/2026.
//
import SwiftUI
struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Startseite (Home) - Contains the article reproduction
            NavigationStack {
                ArticleListView()
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Startseite")
            }
            .tag(0)
            
            // Tab 2: Städte (Cities)
            NavigationStack {
                PlaceholderTabView(title: "Städte", icon: "building.2.fill")
            }
            .tabItem {
                Image(systemName: "building.2.fill")
                Text("Städte")
            }
            .tag(1)
            
            // Tab 3: Suche (Search)
            NavigationStack {
                PlaceholderTabView(title: "Suche", icon: "magnifyingglass")
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Suche")
            }
            .tag(2)
            
            // Tab 4: Mediathek (Media Library)
            NavigationStack {
                PlaceholderTabView(title: "Mediathek", icon: "play.rectangle.fill")
            }
            .tabItem {
                Image(systemName: "play.rectangle.fill")
                Text("Mediathek")
            }
            .tag(3)
            
            // Tab 5: Entdecken (Discover)
            NavigationStack {
                PlaceholderTabView(title: "Entdecken", icon: "compass.fill")
            }
            .tabItem {
                Image(systemName: "compass.fill")
                Text("Entdecken")
            }
            .tag(4)
        }
        .accentColor(.cyan)
    }
}

// MARK: - Article List View (First Tab)

struct ArticleListView: View {
    @State private var articles: [Article] = []
    
    var body: some View {
        List {
            // Special test case at the top
            NavigationLink(destination: NestedLazyVStackView()) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    VStack(alignment: .leading) {
                        Text("Nested LazyVStack Test")
                            .font(.headline)
                        Text("Reproduces hang with Accessibility")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .navigationTitle("Startseite")
        .onAppear {}
    }
}
// MARK: - Placeholder Views for Other Tabs

struct PlaceholderTabView: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.cyan)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            
            Text("This tab is a placeholder")
                .font(.body)
                .foregroundColor(.gray)
        }
        .navigationTitle(title)
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
}
