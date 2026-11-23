import Foundation

final class QuoteCollection: QuoteRepository {
    private(set) var quotes: [Quote]

    init(quotes: [Quote] = []) {
        self.quotes = quotes
    }

    func add(_ quote: Quote) {
        if !quotes.contains(where: { $0.id == quote.id }) {
            quotes.append(quote)
        }
    }

    func filter(by category: QuoteCategory) -> [Quote] {
        quotes.filter { $0.category == category }
    }

    func toggleFavorite(for id: UUID) {
        if let index = quotes.firstIndex(where: { $0.id == id }) {
            quotes[index].isFavorite.toggle()
        }
    }
}