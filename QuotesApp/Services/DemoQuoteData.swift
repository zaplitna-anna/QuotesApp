import Foundation

enum DemoQuoteData {

    static func seedIfNeeded(in repository: any QuoteRepository) {

        let initialQuotes = [
            Quote(
                text: "Найкращий спосіб почати – це перестати говорити та почати діяти.",
                author: "Волт Дісней",
                category: .motivation
            ),
            Quote(
                text: "Я не лінивий. Я просто перебуваю в режимі енергозбереження.",
                author: nil,
                category: .humor
            ),
            Quote(
                text: "Пристрасть — це натхнення тіла, кохання — душі.",
                author: "Ліна Костенко",
                category: .love
            )
        ]

        for quote in initialQuotes {

            let alreadyExists = repository.quotes.contains { existing in
                existing.text.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).caseInsensitiveCompare(
                    quote.text.trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                ) == .orderedSame
            }

            if !alreadyExists {
                repository.add(quote)
            }
        }
    }
}
