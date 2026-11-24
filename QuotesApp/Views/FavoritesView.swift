import SwiftUI

struct FavoritesView: View {

    @ObservedObject var viewModel: QuotesViewModel
    @ObservedObject var router: AppRouter

    var body: some View {
        Group {
            if viewModel.favoriteQuotes.isEmpty {
                ContentUnavailableView(
                    "Обраних цитат немає",
                    systemImage: "heart",
                    description: Text("Додайте цитату до обраного")
                )
            } else {
                List(viewModel.favoriteQuotes) { quote in
                    Button {
                        router.showDetails(for: quote.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(quote.text)
                                .foregroundStyle(.primary)

                            Text(quote.author ?? "Автор невідомий")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Обрані")
    }
}