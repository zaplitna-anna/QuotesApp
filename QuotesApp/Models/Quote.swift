import Foundation

struct Quote: Identifiable, Codable {
    let id: UUID
    var text: String
    var author: String?
    var category: QuoteCategory
    var isFavorite: Bool

    init(id: UUID = UUID(), text: String, author: String? = nil, category: QuoteCategory, isFavorite: Bool = false) {
        self.id = id
        self.text = text
        self.author = author
        self.category = category
        self.isFavorite = isFavorite
    }
}
