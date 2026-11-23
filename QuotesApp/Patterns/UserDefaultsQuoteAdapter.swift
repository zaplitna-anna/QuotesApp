import Foundation

final class UserDefaultsQuoteAdapter: QuoteRepository {
    
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    private let key = "saved_quotes"
   
    var quotes: [Quote] {
        guard let data = defaults.data(forKey: key) else {
            return []
        }
        do {
            return try JSONDecoder().decode([Quote].self, from: data)
        } catch {
            print("Помилка декодування цитат: \(error.localizedDescription)")
            return []
        }
    }
 
    private func save(_ quotes: [Quote]) {
        do {
            let encodedData = try JSONEncoder().encode(quotes)
            defaults.set(encodedData, forKey: key)
        } catch {
            print("Помилка кодування цитат: \(error.localizedDescription)")
        }
    }
    
    func add(_ quote: Quote) {
        var currentQuotes = self.quotes
        if !currentQuotes.contains(where: { $0.id == quote.id }) {
            currentQuotes.append(quote)
            save(currentQuotes)
        }
    }
    
    func filter(by category: QuoteCategory) -> [Quote] {
        return quotes.filter { $0.category == category }
    }
    
    func toggleFavorite(for id: UUID) {
        var currentQuotes = self.quotes
        if let index = currentQuotes.firstIndex(where: { $0.id == id }) {
            currentQuotes[index].isFavorite.toggle()
            save(currentQuotes)
        }
    }
}