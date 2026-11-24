import Foundation

protocol QuoteAPIService: Sendable {
    func fetchQuotes(
        topic: String?,
        cursor: String?
    ) async throws -> QuotesAPIResponse
}

enum QuoteAPIError: LocalizedError, Sendable {
    case invalidURL
    case invalidResponse
    case transport(String)
    case httpStatus(Int)
    case decoding(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Неправильна адреса API."

        case .invalidResponse:
            return "Сервер повернув некоректну відповідь."

        case .transport(let message):
            return "Помилка з'єднання: \(message)"

        case .httpStatus(let code):
            if code == 429 {
                return "Забагато запитів. Спробуйте пізніше."
            }
            return "Помилка сервера. HTTP \(code)."

        case .decoding(let message):
            return "Не вдалося обробити JSON: \(message)"
        }
    }
}
