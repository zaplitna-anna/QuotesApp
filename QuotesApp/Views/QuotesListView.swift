import SwiftUI

struct QuotesListView: View {

    @ObservedObject var viewModel: QuotesViewModel
    @ObservedObject var router: AppRouter

    @State private var showCategoryPicker = false

    var body: some View {
        VStack(spacing: 12) {
            Button {
                showCategoryPicker = true
            } label: {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease")
                        .foregroundStyle(.indigo)

                    Text(
                        viewModel.selectedCategory?.rawValue
                            ?? "Усі категорії"
                    )
                    .foregroundStyle(.primary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.indigo)
                }
                .padding(14)
                .background(
                    Color(uiColor: .secondarySystemGroupedBackground)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            Button {
                if let quote = viewModel.randomQuote() {
                    router.showDetails(for: quote.id)
                }
            } label: {
                Label("Випадкова цитата", systemImage: "shuffle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.indigo)
            .padding(.horizontal)
            .disabled(viewModel.quotes.isEmpty)

            if viewModel.filteredQuotes.isEmpty {
                Spacer()

                Text("У цій категорії цитат немає")
                    .foregroundStyle(.secondary)

                Spacer()
            } else {
                List(viewModel.filteredQuotes) { quote in
                    Button {
                        router.showDetails(for: quote.id)
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(quote.text)
                                .font(.body)
                                .foregroundStyle(.primary)
                                .multilineTextAlignment(.leading)

                            HStack {
                                Text(quote.author ?? "Автор невідомий")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)

                                Spacer()

                                if quote.isFavorite {
                                    Image(systemName: "heart.fill")
                                        .foregroundStyle(.red)
                                }
                            }

                            Text(quote.category.rawValue)
                                .font(.caption2)
                                .foregroundStyle(.indigo)
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("QuotesApp")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    router.showFavorites()
                } label: {
                    Image(systemName: "heart")
                }
                .accessibilityLabel("Обрані цитати")
            }

            ToolbarItemGroup(placement: .topBarTrailing) {

                Button {
                    router.showOnlineQuotes()
                } label: {
                    Image(systemName: "globe")
                }
                .accessibilityLabel("Онлайн-цитати")

                Button {
                    router.showAddQuote()
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Додати цитату")
            }
        }
        .tint(.indigo)
        .sheet(isPresented: $showCategoryPicker) {
            CategorySelectionSheet(
                title: "Фільтр категорій",
                includeAll: true,
                selectedCategory: viewModel.selectedCategory
            ) { category in
                viewModel.selectedCategory = category
            }
        }
    }
}
