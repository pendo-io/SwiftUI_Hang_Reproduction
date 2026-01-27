//
//  Models.swift
//  Rumble_Hang
//
//  Created by Michael Rozenblat on 27/01/2026.
//

import Foundation
import SwiftUI
import Combine

// MARK: - Article Models

struct Article: Identifiable {
    let id: UUID
    let title: String
    let isTrialArticle: Bool
    let content: [ArticleContentItem]
    let teaser: String
    let imageURL: URL?
    
    init(id: UUID = UUID(), title: String, isTrialArticle: Bool = false, content: [ArticleContentItem] = [], teaser: String = "Teaser text", imageURL: URL? = nil) {
        self.id = id
        self.title = title
        self.isTrialArticle = isTrialArticle
        self.content = content
        self.teaser = teaser
        self.imageURL = imageURL
    }
}

enum ArticleContentItem: Identifiable {
    case paragraph(String)
    case heading(String)
    case image(URL)
    
    var id: String {
        switch self {
        case .paragraph(let s): return "p-\(s.hashValue)"
        case .heading(let s): return "h-\(s.hashValue)"
        case .image(let u): return "i-\(u.hashValue)"
        }
    }
}

// MARK: - Article Detail View Data

class ArticleDetailViewData: ObservableObject {
    
    @Published var showError = false
    @Published var errorMessage = ""
    @Published var selectedEmbed: String?
    @Published var showConsentBanner = false
    @Published var userAcceptedConsent = false
    @Published var oneTimeConsentIsGiven = false
}

// MARK: - Article Store

class ArticleStore: ObservableObject {
    @Published var recommendedArticlesLoadingState: Result<[Article], Error> = .success([])
    @Published var paginatedArticles: [Article] = []
    @Published var hasNext: Bool = true
    @Published var cursor: String? = nil
    
    init() {
        loadInitialArticles()
    }
    
    func loadInitialArticles() {
        let initial = (0..<5).map { i in 
            Article(
                title: "Pfarrer Thomas Roddey ist Polizeiseelsorger - Für mich sind das die Guten",
                imageURL: URL(string: "https://picsum.photos/150/150?random=\(i)")
            )
        }
        recommendedArticlesLoadingState = .success(initial)
    }
    
    func fetchMoreArticles(articleID: UUID, after: String?, tokenData: Any?) async {
        try? await Task.sleep(nanoseconds: 1_000_000_00)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let newArticles = (0..<5).map { i in Article(title: "Paginated Article with a very long title that should span multiple lines \(self.paginatedArticles.count + i)", imageURL: URL(string: "https://picsum.photos/150/150?random=\(self.paginatedArticles.count + i)")) }
            self.paginatedArticles.append(contentsOf: newArticles)
            
            if self.paginatedArticles.count > 1000 {
                self.hasNext = false
            }
        }
    }
}
