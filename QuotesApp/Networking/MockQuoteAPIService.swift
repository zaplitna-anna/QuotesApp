import Foundation

struct MockQuoteAPIService: QuoteAPIService {

    enum Mode: Sendable {
        case empty
        case transportError
        case httpError
        case decodingError
    }

    let mode: Mode

    func fetchQuotes(
        topic: String?,
        cursor: String? = nil
    ) async throws -> QuotesAPIResponse {

        try await Task.sleep(for: .seconds(1))

        switch mode {
        case .empty:
            return QuotesAPIResponse(
                quotes: [],
                nextCursor: nil
            )

        case .transportError:
            throw QuoteAPIError.transport(
                "Немає з'єднання із сервером."
            )

        case .httpError:
            throw QuoteAPIError.httpStatus(500)

        case .decodingError:
            throw QuoteAPIError.decoding(
                "Невідповідність структури JSON."
            )
        }
    }
}
