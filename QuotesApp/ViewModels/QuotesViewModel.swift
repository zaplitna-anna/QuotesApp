import Foundation
import Combine

final class QuotesViewModel: ObservableObject {

    @Published private(set) var quotes: [Quote] = []
    @Published var selectedCategory: QuoteCategory? = nil

    private let repository: any QuoteRepository

    init(repository: any QuoteRepository) {
        self.repository = repository
        refresh()
    }

    func refresh() {
        quotes = repository.quotes
    }

    func filterQuotes(using strategy: any FilterStrategy) -> [Quote] {
        strategy.filter(quotes)
    }

    var filteredQuotes: [Quote] {
        if let category = selectedCategory {
            return filterQuotes(
                using: CategoryFilterStrategy(category: category)
            )
        }

        return filterQuotes(using: AllQuotesStrategy())
    }

    var favoriteQuotes: [Quote] {
        filterQuotes(using: FavoritesFilterStrategy())
    }

    func quote(with id: UUID) -> Quote? {
        quotes.first { $0.id == id }
    }

    func randomQuote() -> Quote? {
        quotes.randomElement()
    }

    @discardableResult
    func addQuote(
        text: String,
        author: String,
        category: QuoteCategory
    ) -> Bool {

        let cleanText = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let cleanAuthor = author.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let isDuplicate = quotes.contains {
            $0.text.trimmingCharacters(in: .whitespacesAndNewlines)
                .caseInsensitiveCompare(cleanText) == .orderedSame
        }

        guard !isDuplicate else {
            return false
        }

        guard let newQuote = QuoteBuilder()
            .setText(cleanText)
            .setAuthor(cleanAuthor.isEmpty ? nil : cleanAuthor)
            .setCategory(category)
            .setFavorite(false)
            .build()
        else {
            return false
        }

        repository.add(newQuote)
        refresh()

        return true
    }

    func toggleFavorite(for id: UUID) {
        repository.toggleFavorite(for: id)
        refresh()
    }
}