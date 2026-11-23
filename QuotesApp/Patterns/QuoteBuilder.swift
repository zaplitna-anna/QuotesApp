import Foundation

final class QuoteBuilder {
    private var text: String = ""
    private var author: String? = nil
    private var category: QuoteCategory = .motivation
    private var isFavorite: Bool = false
    
    func setText(_ text: String) -> Self {
        self.text = text
        return self
    }
    
    func setAuthor(_ author: String?) -> Self {
        self.author = author
        return self
    }
    
    func setCategory(_ category: QuoteCategory) -> Self {
        self.category = category
        return self
    }
    
    func setFavorite(_ isFavorite: Bool) -> Self {
        self.isFavorite = isFavorite
        return self
    }
    
    func build() -> Quote? {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        return Quote(
            text: text,
            author: author,
            category: category,
            isFavorite: isFavorite
        )
    }
}