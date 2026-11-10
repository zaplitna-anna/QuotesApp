import Foundation

protocol QuoteStorage {
    func add(_ quote: Quote)
    func filter(by category: QuoteCategory) -> [Quote]
    func find(by id: UUID) -> Quote?
}

final class QuoteCollection: QuoteStorage {
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

    func find(by id: UUID) -> Quote? {
        quotes.first { $0.id == id }
    }

    func toggleFavorite(for id: UUID) {
        if let index = quotes.firstIndex(where: { $0.id == id }) {
            quotes[index].isFavorite.toggle()
        }
    }
}