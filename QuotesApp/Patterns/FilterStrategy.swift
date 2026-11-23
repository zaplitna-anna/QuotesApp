import Foundation

protocol FilterStrategy {
    func filter(_ quotes: [Quote]) -> [Quote]
}

struct AllQuotesStrategy: FilterStrategy {
    func filter(_ quotes: [Quote]) -> [Quote] {
        return quotes
    }
}

struct FavoritesFilterStrategy: FilterStrategy {
    func filter(_ quotes: [Quote]) -> [Quote] {
        return quotes.filter { $0.isFavorite }
    }
}

struct CategoryFilterStrategy: FilterStrategy {
    let category: QuoteCategory
    
    func filter(_ quotes: [Quote]) -> [Quote] {
        return quotes.filter { $0.category == category }
    }
}