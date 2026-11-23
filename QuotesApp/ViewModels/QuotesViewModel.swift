import Foundation
import Combine

final class QuotesViewModel: ObservableObject {

    @Published var demoOutput: String =
        "Натисніть кнопку, щоб запустити MVVM сценарій."

    private let storage: any QuoteRepository

    init(storage: any QuoteRepository) {
        self.storage = storage
    }

    func filterQuotes(using strategy: any FilterStrategy) -> [Quote] {
        strategy.filter(storage.quotes)
    }

    func runDemo() {
        var log = "СТАРТ СЦЕНАРІЮ\n\n"
        let quoteText = "Дизайн - це не те, як предмет виглядає, а те, як він працює."
        let newQuote: Quote

        if let existingQuote = storage.quotes.first(where: {
            $0.text.trimmingCharacters(in: .whitespacesAndNewlines)
                .caseInsensitiveCompare(quoteText) == .orderedSame
        }) {
            newQuote = existingQuote
            log += "Цитата вже існує у сховищі. Дублікат не створено.\n"
        } else {
            guard let createdQuote = QuoteBuilder()
                .setText(quoteText)
                .setAuthor("Стів Джобс")
                .setCategory(.motivation)
                .setFavorite(false)
                .build()
            else {
                demoOutput = "Помилка: текст цитати не може бути порожнім."
                return
            }
            storage.add(createdQuote)
            newQuote = createdQuote
            log += "Цитату створено через Builder та додано до сховища.\n"
        }

        if !newQuote.isFavorite {
            storage.toggleFavorite(for: newQuote.id)
            log += "Цитату додано в обране.\n\n"
        } else {
            log += "Цитата вже перебуває в обраному.\n\n"
        }

        let favoriteQuotes = filterQuotes(
            using: FavoritesFilterStrategy()
        )

        log += "Фільтр: тільки обрані\n"

        for quote in favoriteQuotes {
            let author = quote.author ?? "Автор невідомий"
            log += "\"\(quote.text)\" — \(author)\n"
        }

        let motivationQuotes = filterQuotes(
            using: CategoryFilterStrategy(category: .motivation)
        )

        log += "\nФільтр: категорія Мотивація\n"

        for quote in motivationQuotes {
            let author = quote.author ?? "Автор невідомий"
            log += "📖 \"\(quote.text)\" — \(author)\n"
        }

        log += "\nСЦЕНАРІЙ ЗАВЕРШЕНО"

        demoOutput = log
        print(log)
    }
}
