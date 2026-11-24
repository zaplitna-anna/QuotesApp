import Foundation
import Combine

@MainActor
final class RemoteQuotesViewModel: ObservableObject {

    enum LoadState {
        case idle
        case loading
        case success([RemoteQuote])
        case empty
        case failure(String)
    }

    private struct CategoryCache {
        var quotes: [RemoteQuote] = []
        var shownIDs: Set<Int> = []
        var nextCursor: String?
        var hasLoaded = false
    }

    @Published private(set) var state: LoadState = .idle
    @Published var selectedCategory: QuoteCategory?

    private let service: any QuoteAPIService

    private var caches: [String: CategoryCache] = [:]
    private var currentRequestID: UUID?

    private let displayCount = 5

    init(service: any QuoteAPIService) {
        self.service = service
    }

    var isLoading: Bool {
        if case .loading = state {
            return true
        }
        return false
    }

    private var topic: String? {
        switch selectedCategory {
        case .motivation:
            return "motivation"
        case .humor:
            return "humor"
        case .love:
            return "love"
        case nil:
            return nil
        }
    }

    func loadQuotes() async {
        let requestID = UUID()
        currentRequestID = requestID

        let requestedTopic = topic
        let key = requestedTopic ?? "popular"

        state = .loading

        var cache = caches[key] ?? CategoryCache()

        do {
            if !cache.hasLoaded {
                let firstPage = try await service.fetchQuotes(
                    topic: requestedTopic,
                    cursor: nil
                )

                try Task.checkCancellation()

                addUnique(firstPage.quotes, to: &cache)
                cache.nextCursor = firstPage.nextCursor
                cache.hasLoaded = true
                if !cache.quotes.isEmpty,
                    let cursor = cache.nextCursor {

                    let secondPage = try await service.fetchQuotes(
                        topic: requestedTopic,
                        cursor: cursor
                    )

                    try Task.checkCancellation()

                    addUnique(secondPage.quotes, to: &cache)

                    cache.nextCursor =
                        secondPage.nextCursor == cursor
                        ? nil
                        : secondPage.nextCursor
                }
            }
            let unusedCount = cache.quotes.filter {
                !cache.shownIDs.contains($0.id)
            }.count

            if unusedCount < displayCount,
                let cursor = cache.nextCursor {

                let nextPage = try await service.fetchQuotes(
                    topic: requestedTopic,
                    cursor: cursor
                )

                try Task.checkCancellation()

                addUnique(nextPage.quotes, to: &cache)

                cache.nextCursor =
                    nextPage.nextCursor == cursor
                    ? nil
                    : nextPage.nextCursor
            }

            guard !Task.isCancelled,
                currentRequestID == requestID else {
                return
            }

            let selected = makeRandomSelection(from: &cache)

            caches[key] = cache

            if selected.isEmpty {
                state = .empty
            } else {
                state = .success(selected)
            }

        } catch is CancellationError {
            return

        } catch {
            guard !Task.isCancelled,
                  currentRequestID == requestID else {
                return
            }

            state = .failure(error.localizedDescription)
        }
    }

    private func addUnique(
        _ newQuotes: [RemoteQuote],
        to cache: inout CategoryCache
    ) {
        var existingIDs = Set(cache.quotes.map(\.id))

        for quote in newQuotes {
            guard !existingIDs.contains(quote.id) else {
                continue
            }

            guard !quote.displayText.trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty else {
                continue
            }

            cache.quotes.append(quote)
            existingIDs.insert(quote.id)
        }
    }

    private func makeRandomSelection(
        from cache: inout CategoryCache
    ) -> [RemoteQuote] {

        guard !cache.quotes.isEmpty else {
            return []
        }

        let unused = cache.quotes.filter {
            !cache.shownIDs.contains($0.id)
        }

        var selected = Array(
            unused.shuffled().prefix(displayCount)
        )

        if selected.count < displayCount {
            let selectedIDs = Set(selected.map(\.id))

            let available = cache.quotes.filter {
                !selectedIDs.contains($0.id)
            }

            let needed = displayCount - selected.count

            selected.append(
                contentsOf: available.shuffled().prefix(needed)
            )
        }

        for quote in selected {
            cache.shownIDs.insert(quote.id)
        }
        if cache.shownIDs.count >= cache.quotes.count {
            cache.shownIDs.removeAll()
            cache.shownIDs.formUnion(selected.map(\.id))
        }

        return selected.shuffled()
    }
}
