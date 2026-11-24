import Foundation

struct RemoteQuoteLine: Decodable, Sendable {
    let body: String
    let author: String?
    let position: Int?
}

struct RemoteQuote: Decodable, Identifiable, Sendable {
    let id: Int
    let body: String?
    let author: String?
    let topics: [String]
    let lines: [RemoteQuoteLine]

    enum CodingKeys: String, CodingKey {
        case id
        case body
        case author
        case topics
        case lines
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        id = try container.decode(Int.self, forKey: .id)

        body = try container.decodeIfPresent(
            String.self,
            forKey: .body
        )

        author = try container.decodeIfPresent(
            String.self,
            forKey: .author
        )

        topics = try container.decodeIfPresent(
            [String].self,
            forKey: .topics
        ) ?? []

        lines = try container.decodeIfPresent(
            [RemoteQuoteLine].self,
            forKey: .lines
        ) ?? []
    }

    var displayText: String {
        if let body, !body.isEmpty {
            return body
        }

        return lines
            .sorted { ($0.position ?? 0) < ($1.position ?? 0) }
            .map { line in
                if let author = line.author, !author.isEmpty {
                    return "\(author): \(line.body)"
                }

                return line.body
            }
            .joined(separator: "\n")
    }

    var displayAuthor: String {
        if let author, !author.isEmpty {
            return author
        }

        if !lines.isEmpty {
            return "Діалог"
        }

        return "Автор невідомий"
    }
}

struct QuotesAPIResponse: Decodable, Sendable {
    let quotes: [RemoteQuote]
    let nextCursor: String?

    enum CodingKeys: String, CodingKey {
        case quotes
        case nextCursor = "next_cursor"
    }

    init(quotes: [RemoteQuote], nextCursor: String?) {
    self.quotes = quotes
    self.nextCursor = nextCursor
    }
}
