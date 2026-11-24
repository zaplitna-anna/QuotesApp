import SwiftUI

struct CategorySelectionSheet: View {

    @Environment(\.dismiss) private var dismiss

    let title: String
    let includeAll: Bool
    let selectedCategory: QuoteCategory?
    let onSelect: (QuoteCategory?) -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {

                    if includeAll {
                        categoryRow(
                            title: "Усі категорії",
                            isSelected: selectedCategory == nil
                        ){
                            select(nil)
                        }
                    }

                    ForEach(QuoteCategory.allCases, id: \.self) { category in
                        categoryRow(
                            title: category.rawValue,
                            isSelected: selectedCategory == category
                        ) {
                            select(category)
                        }
                    }
                }
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Закрити") {
                        dismiss()
                    }
                    .tint(.indigo)
                }
            }
        }
        .tint(.indigo)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(
            Color(uiColor: .systemGroupedBackground)
        )
    }

    
    private func categoryRow(
        title: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.indigo)
                }
            }
            .padding(16)
            .background(
                isSelected
                    ? Color.indigo.opacity(0.12)
                    : Color(uiColor: .secondarySystemGroupedBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }


    private func select(_ category: QuoteCategory?) {
        onSelect(category)
        dismiss()
    }
}
