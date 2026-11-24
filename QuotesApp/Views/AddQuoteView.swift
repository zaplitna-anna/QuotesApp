import SwiftUI

struct AddQuoteView: View {

    @ObservedObject var viewModel: QuotesViewModel
    @ObservedObject var router: AppRouter

    @State private var text = ""
    @State private var author = ""
    @State private var category: QuoteCategory = .motivation

    @State private var showCategoryPicker = false
    @State private var showDuplicateAlert = false

    @FocusState private var isInputFocused: Bool

    private var isTextValid: Bool {
        !text.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Текст цитати") {
                    TextEditor(text: $text)
                        .frame(minHeight: 130)
                        .focused($isInputFocused)
                }

                Section("Автор") {
                    TextField("Введіть автора", text: $author)
                        .focused($isInputFocused)
                }

                Section("Категорія") {
                    Button {
                        isInputFocused = false
                        showCategoryPicker = true
                    } label: {
                        HStack {
                            Text(category.rawValue)
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundStyle(.indigo)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            .scrollContentBackground(.hidden)
            .background(
                Color(uiColor: .systemGroupedBackground)
            )
            .scrollDismissesKeyboard(.immediately)
            .navigationTitle("Нова цитата")
            .navigationBarTitleDisplayMode(.inline)
            .tint(.indigo)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Скасувати") {
                        isInputFocused = false
                        router.dismissAddQuote()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Зберегти") {
                        saveQuote()
                    }
                    .fontWeight(.semibold)
                    .disabled(!isTextValid)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Готово") {
                        isInputFocused = false
                    }
                }
            }
            .sheet(isPresented: $showCategoryPicker) {
                CategorySelectionSheet(
                    title: "Категорія цитати",
                    includeAll: false,
                    selectedCategory: category
                ) { selected in
                    if let selected {
                        category = selected
                    }
                }
            }
            .overlay {
                if showDuplicateAlert {
                    duplicateAlert
                        .transition(.opacity.combined(with: .scale))
                        .zIndex(1)
                }
            }
        }
    }

    private var duplicateAlert: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("Не вдалося додати цитату")
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text("Цитата з таким текстом уже існує.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    withAnimation {
                        showDuplicateAlert = false
                    }
                } label: {
                    Text("Зрозуміло")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(12)
                }
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
            }
            .padding(24)
            .frame(maxWidth: 320)
            .background(
                Color(uiColor: .systemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: .black.opacity(0.15), radius: 20)
            .padding(.horizontal, 24)
        }
    }

    private func saveQuote() {
        let success = viewModel.addQuote(
            text: text,
            author: author,
            category: category
        )

        if success {
            isInputFocused = false
            router.dismissAddQuote()
        } else {
            isInputFocused = false

            withAnimation(.easeInOut(duration: 0.2)) {
                showDuplicateAlert = true
            }
        }
    }
}
