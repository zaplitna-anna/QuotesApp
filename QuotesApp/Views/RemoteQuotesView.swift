import SwiftUI

struct RemoteQuotesView: View {

    @StateObject private var viewModel: RemoteQuotesViewModel
    @ObservedObject var localViewModel: QuotesViewModel

    @State private var showFilterPicker = false
    @State private var quoteToSave: RemoteQuote?
    @State private var saveErrorMessage: String?

    init(
        service: any QuoteAPIService,
        localViewModel: QuotesViewModel
    ) {
        _viewModel = StateObject(
            wrappedValue: RemoteQuotesViewModel(
                service: service
            )
        )

        self.localViewModel = localViewModel
    }

    var body: some View {
        VStack(spacing: 12) {

            categoryButton

            Group {
                switch viewModel.state {

                case .idle:
                    ProgressView("Підготовка...")
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )

                case .loading:
                    ProgressView("Завантаження цитат...")
                        .frame(
                            maxWidth: .infinity,
                            maxHeight: .infinity
                        )

                case .success(let quotes):
                    List(quotes) { quote in
                        quoteRow(quote)
                    }
                    .listStyle(.plain)

                case .empty:
                    ContentUnavailableView {
                        Text("Цитат не знайдено")
                    } description: {
                        Text("Для цієї категорії немає цитат.")
                    } actions: {
                        retryButton
                    }

                case .failure(let message):
                    ContentUnavailableView {
                        Text("Помилка завантаження")
                    } description: {
                        Text(message)
                    } actions: {
                        retryButton
                    }
                }
            }
        }
        .background(Color(uiColor: .systemBackground))
        .navigationTitle("Онлайн-цитати")
        .navigationBarTitleDisplayMode(.inline)
        .tint(.indigo)

        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Оновити") {
                    Task {
                        await viewModel.loadQuotes()
                    }
                }
                .disabled(viewModel.isLoading)
            }
        }

        .sheet(isPresented: $showFilterPicker) {
            CategorySelectionSheet(
                title: "Фільтр категорій",
                includeAll: true,
                selectedCategory: viewModel.selectedCategory
            ) { category in
                viewModel.selectedCategory = category
            }
        }

        .sheet(item: $quoteToSave) { quote in
            CategorySelectionSheet(
                title: "Категорія цитати",
                includeAll: false,
                selectedCategory: .motivation
            ) { category in
                if let category {
                    saveQuote(quote, category: category)
                }
            }
        }

        .alert(
            "Не вдалося зберегти цитату",
            isPresented: Binding(
                get: { saveErrorMessage != nil },
                set: { if !$0 { saveErrorMessage = nil } }
            )
        ) {
            Button("Зрозуміло", role: .cancel) {
                saveErrorMessage = nil
            }
        } message: {
            Text(saveErrorMessage ?? "")
        }

        .task(id: viewModel.selectedCategory) {
            await viewModel.loadQuotes()
        }
    }

    private var categoryButton: some View {
        Button {
            showFilterPicker = true
        } label: {
            HStack {
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
            .clipShape(
                RoundedRectangle(cornerRadius: 12)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    private func quoteRow(_ quote: RemoteQuote) -> some View {
        Button {
            guard !isSaved(quote) else {
                return
            }

            quoteToSave = quote

        } label: {
            VStack(alignment: .leading, spacing: 12) {

                Text(quote.displayText)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fixedSize(
                        horizontal: false,
                        vertical: true
                    )

                Text(quote.displayAuthor)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if !quote.topics.isEmpty {
                    Text(
                        quote.topics.joined(separator: ", ")
                    )
                    .font(.caption2)
                    .foregroundStyle(.indigo)
                }

                if isSaved(quote) {
                    Text("Уже збережено")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(
                maxWidth: .infinity,
                alignment: .leading
            )
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isSaved(quote))
        .padding(.vertical, 4)
    }

    private var retryButton: some View {
        Button("Повторити") {
            Task {
                await viewModel.loadQuotes()
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(.indigo)
    }

    private func isSaved(_ quote: RemoteQuote) -> Bool {
        let text = quote.displayText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        return localViewModel.quotes.contains {
            $0.text.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .caseInsensitiveCompare(text) == .orderedSame
        }
    }

    private func saveQuote(
        _ quote: RemoteQuote,
        category: QuoteCategory
    ) {
        let text = quote.displayText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !text.isEmpty else {
            saveErrorMessage = "Текст цитати порожній."
            return
        }

        guard !isSaved(quote) else {
            saveErrorMessage = "Цю цитату вже збережено."
            return
        }

        let author: String

        if quote.displayAuthor == "Автор невідомий" {
            author = ""
        } else {
            author = quote.displayAuthor
        }

        let success = localViewModel.addQuote(
            text: text,
            author: author,
            category: category
        )

        if !success {
            saveErrorMessage = "Не вдалося додати цитату."
        }
    }
}
