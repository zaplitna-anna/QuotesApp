import Foundation

protocol QuoteRepository {
    var quotes: [Quote] { get }
    func add(_ quote: Quote)
    func filter(by category: QuoteCategory) -> [Quote]
    func toggleFavorite(for id: UUID)
}