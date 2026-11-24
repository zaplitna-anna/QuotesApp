import Foundation

struct URLSessionQuoteAPIService: QuoteAPIService {

    private let baseURL = "https://favqs.com/api/v3"

    func fetchQuotes(
        topic: String?,
        cursor: String? = nil
    ) async throws -> QuotesAPIResponse {

        let endpoint: String

        if let topic {
            let allowed = CharacterSet.urlPathAllowed
                .subtracting(CharacterSet(charactersIn: "/"))

            guard let encoded = topic.addingPercentEncoding(
                withAllowedCharacters: allowed
            ) else {
                throw QuoteAPIError.invalidURL
            }

            endpoint = "/topics/\(encoded)/quotes"
        } else {
            endpoint = "/quotes/popular"
        }

        guard var components = URLComponents(
            string: baseURL + endpoint
        ) else {
            throw QuoteAPIError.invalidURL
        }

        var queryItems = [
            URLQueryItem(name: "limit", value: "10")
        ]

        if let cursor, !cursor.isEmpty {
            queryItems.append(
                URLQueryItem(name: "cursor", value: cursor)
            )
        }

        components.queryItems = queryItems

        guard let url = components.url else {
            throw QuoteAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await URLSession.shared.data(
                for: request
            )
        } catch let error as URLError
            where error.code == .cancelled {
            throw CancellationError()
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw QuoteAPIError.transport(
                error.localizedDescription
            )
        }

        try Task.checkCancellation()

        guard let httpResponse = response as? HTTPURLResponse else {
            throw QuoteAPIError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw QuoteAPIError.httpStatus(
                httpResponse.statusCode
            )
        }

        do {
            return try JSONDecoder().decode(
                QuotesAPIResponse.self,
                from: data
            )
        } catch {
            throw QuoteAPIError.decoding(
                error.localizedDescription
            )
        }
    }
}
