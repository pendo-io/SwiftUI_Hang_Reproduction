//
//  MainTabView.swift
//  Rumble_Hang
//
//  Created by Michael Rozenblat on 27/01/2026.
//

import SwiftUI
import SDWebImageSwiftUI

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
            ForEach(articles) { article in
                NavigationLink(destination: ArticleDetailView(article: article)) {
                    ArticleRowView(article: article)
                }
            }
        }
        .navigationTitle("Startseite")
        .onAppear {
            loadArticles()
        }
    }
    
    private func loadArticles() {
        // Generate sample articles for the list
        articles = (0..<10).map { i in
            Article(
                title: "Article \(i + 1): Pfarrer Thomas Roddey ist Polizeiseelsorger",
                isTrialArticle: i == 0,
                content: [
                    .heading("Introduction"),
                    .paragraph("This is the main article content. It is long enough to push the recommended articles down."),
                    .paragraph("More text here to fill space."),
                    .image(URL(string: "https://picsum.photos/300/200?random=\(i)")!),
                    .paragraph("Conclusion text.")
                ],
                imageURL: URL(string: "https://picsum.photos/150/150?random=\(i)")
            )
        }
    }
}

struct ArticleRowView: View {
    let article: Article
    
    var body: some View {
        HStack(spacing: 12) {
            if let url = article.imageURL {
                WebImage(url: url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .clipped()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(2)
                
                if article.isTrialArticle {
                    Text("Trial Article")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
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
