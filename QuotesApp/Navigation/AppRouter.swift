import SwiftUI
import Combine

enum QuoteRoute: Hashable {
    case details(UUID)
    case favorites
    case onlineQuotes
}

final class AppRouter: ObservableObject {

    @Published var path: [QuoteRoute] = []
    @Published var isShowingAddQuote = false

    func showDetails(for id: UUID) {
        path.append(.details(id))
    }

    func showFavorites() {
        path.append(.favorites)
    }

    func showAddQuote() {
        isShowingAddQuote = true
    }

    func dismissAddQuote() {
        isShowingAddQuote = false
    }

    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func goToRoot() {
        path.removeAll()
    }

    func showOnlineQuotes() {
    path.append(.onlineQuotes)
    }
}