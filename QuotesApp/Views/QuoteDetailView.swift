import SwiftUI

struct QuoteDetailView: View {

    let quoteID: UUID

    @ObservedObject var viewModel: QuotesViewModel

    var body: some View {
        Group {
            if let quote = viewModel.quote(with: quoteID) {

                ScrollView {
                    VStack(spacing: 24) {
                        Text(quote.text)
                            .font(.title2)
                            .multilineTextAlignment(.center)

                        Text(quote.author ?? "Автор невідомий")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        Text(quote.category.rawValue)
                            .font(.subheadline)
                            .foregroundStyle(.indigo)

                        Button {
                            withAnimation(
                                .spring(
                                    response: 0.35,
                                    dampingFraction: 0.5
                                )
                            ) {
                                viewModel.toggleFavorite(for: quote.id)
                            }
                        } label: {
                            VStack(spacing: 8) {
                                Image(
                                    systemName: quote.isFavorite
                                        ? "heart.fill"
                                        : "heart"
                                )
                                .font(.system(size: 50))
                                .foregroundStyle(.red)
                                .scaleEffect(quote.isFavorite ? 1.25 : 1.0)

                                Text(
                                    quote.isFavorite
                                        ? "Видалити з обраного"
                                        : "Додати в обране"
                                )
                            }
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(
                            quote.isFavorite
                                ? "Видалити з обраного"
                                : "Додати в обране"
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(24)
                }
            } else {
                ContentUnavailableView(
                    "Цитату не знайдено",
                    systemImage: "exclamationmark.bubble"
                )
            }
        }
        .navigationTitle("Деталі цитати")
        .navigationBarTitleDisplayMode(.inline)
    }
}