import SwiftUI

@main
struct QuotesApp: App {
    @StateObject private var viewModel: QuotesViewModel
    init() {
        let storage = UserDefaultsQuoteAdapter()
        _viewModel = StateObject(
            wrappedValue: QuotesViewModel(storage: storage)
        )
    }
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}