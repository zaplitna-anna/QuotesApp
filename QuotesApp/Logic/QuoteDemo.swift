import Foundation

enum QuoteDemo {
    static func run() {
        print("СТАРТ СЦЕНАРІЮ")
        
        let storage = QuoteCollection()
        print("Створено порожнє сховище цитат.")

        let quote1 = Quote(text: "Найкращий спосіб почати – це перестати говорити та почати діяти.", author: "Волт Дісней", category: .motivation)
        let quote2 = Quote(text: "Я не лінивий. Я просто перебуваю в режимі енергозбереження.", author: nil, category: .humor)
        let quote3 = Quote(text: "Пристрасть — це натхнення тіла, кохання — душі.", author: "Ліна Костенко", category: .love)

        storage.add(quote1)
        storage.add(quote2)
        storage.add(quote3)
        print("Додано 3 цитати до колекції.")

        storage.add(quote1)
        print("Спроба додати дублікат. Кількість цитат: \(storage.quotes.count)")

        print("\nЗміна статусу 'Обране':")
        print("До зміни: цитата 1 в обраному? \(storage.quotes[0].isFavorite)")
        storage.toggleFavorite(for: quote1.id)
        print("Після зміни: цитата 1 в обраному? \(storage.quotes[0].isFavorite)")

        print("\nФільтрація (Мотивація):")
        let motivationQuotes = storage.filter(by: .motivation)
        if motivationQuotes.isEmpty {
            print("У цій категорії цитат немає.")
        } else {
            for quote in motivationQuotes {
                let authorName = quote.author ?? "Автор невідомий"
                let favoriteIcon = quote.isFavorite ? "❤️" : "🤍"
                print("\(favoriteIcon) \"\(quote.text)\" — \(authorName)")
            }
        }

        print("\nФільтрація (Гумор - без автора):")
        let humorQuotes = storage.filter(by: .humor)
        for quote in humorQuotes {
            if let safeAuthor = quote.author {
                print("\"\(quote.text)\" — \(safeAuthor)")
            } else {
                print("\"\(quote.text)\" — Народна мудрість")
            }
        }
        
        print("\nСЦЕНАРІЙ ЗАВЕРШЕНО")
    }
}