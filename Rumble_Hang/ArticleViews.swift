//
//  ArticleViews.swift
//  Rumble_Hang
//
//  Created by Michael Rozenblat on 27/01/2026.
//

import SwiftUI
import SDWebImageSwiftUI

// MARK: - Main Article Detail View

struct ArticleDetailView: View {
    let article: Article
    
    @StateObject private var articleDetailViewData = ArticleDetailViewData()
    @StateObject private var articleStore = ArticleStore()
    @State private var selectedArticleID: UUID?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if article.isTrialArticle {
                    TrialArticleHeader()
                }
                
                ArticleHeader(
                    article: article,
                    showError: $articleDetailViewData.showError,
                    errorMessage: $articleDetailViewData.errorMessage
                )
                .padding(.bottom)
                
                ArticleContentView(article: article)
                    .padding(.top)
                    .padding(.horizontal)
                
                if !article.content.isEmpty {
                    ReadMoreArticles(
                        errorMessage: $articleDetailViewData.errorMessage,
                        showError: $articleDetailViewData.showError,
                        articleID: article.id,
                        selectedArticleID: $selectedArticleID,
                        articleStore: articleStore
                    )
                    .padding(.top, 24)
                    .background(Color.gray.opacity(0.1))
                }
            }
            .frame(maxWidth: 600)
            
            MiniPlayerSpacer()
        }
        .background(Color(white: 0.95))
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Read More Articles Section

struct ReadMoreArticles: View {
    @Binding var errorMessage: String
    @Binding var showError: Bool
    let articleID: UUID
    @Binding var selectedArticleID: UUID?
    @ObservedObject var articleStore: ArticleStore
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 18) {
            if case .success(let articles) = articleStore.recommendedArticlesLoadingState {
                LazyVStack(spacing: 12) {
                    ForEach(articles) { article in
                        LazyVStack (spacing:1) {
                            JuniorTeaser(article: article)
                                .onTapGesture {
                                    selectedArticleID = article.id
                                }
                                .accessibilityIdentifier("articleDetail-recommended-article-\(articles.firstIndex(where: { $0.id == article.id }) ?? 0)")
                        }
                    }
                    
                    ForEach(articleStore.paginatedArticles) { article in
                        LazyVStack (spacing:1) {
                            JuniorTeaser(article: article)
                                .onTapGesture {
                                    selectedArticleID = article.id
                                }
                                .accessibilityIdentifier("articleDetail-paginated-recommended-article-\(articleStore.paginatedArticles.firstIndex(where: { $0.id == article.id }) ?? 0)")
                        }
                    }
                }
                .padding(.horizontal)
                
                if articleStore.hasNext {
                    Button(action: {
                        Task {
                            await articleStore.fetchMoreArticles(articleID: articleID, after: nil, tokenData: nil)
                        }
                    }) {
                        HStack {
                            Image(systemName: "chevron.down")
                            Text("Mehr")
                                .font(.headline)
                        }
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .padding(.horizontal)
                    }
                    .accessibilityIdentifier("articleDetail-recommended-articles-load-more-button")
                }
            }
        }
        .padding(.top, 20)
    }
}

// MARK: - Component Views

struct TrialArticleHeader: View {
    var body: some View {
        Text("Trial Article")
            .font(.caption)
            .padding(4)
            .background(Color.orange.opacity(0.3))
            .cornerRadius(4)
            .padding(.bottom)
    }
}

struct ArticleHeader: View {
    let article: Article
    @Binding var showError: Bool
    @Binding var errorMessage: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(article.title)
                .font(.largeTitle)
                .bold()
                .padding(.horizontal)
            
            if let url = article.imageURL {
                WebImage(url: url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
            }
        }
        .background(Color.white)
    }
}

struct ArticleContentView: View {
    let article: Article
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(article.content) { item in
                switch item {
                case .paragraph(let text):
                    Text(text)
                        .font(.body)
                case .heading(let text):
                    Text(text)
                        .font(.title2)
                        .bold()
                case .image(let url):
                    WebImage(url: url)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct JuniorTeaser: View {
    let article: Article
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                Text(article.title)
                    .font(.headline)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(.black)
                
                Text("DORTMUND gestern")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            if let url = article.imageURL {
                WebImage(url: url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .cornerRadius(8)
                    .clipped()
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct MiniPlayerSpacer: View {
    var body: some View {
        Spacer().frame(height: 50)
    }
}
