import SwiftUI

@main
struct QuotesApp: App {

    @StateObject private var viewModel: QuotesViewModel
    @StateObject private var router = AppRouter()

    init() {
        let repository: any QuoteRepository = UserDefaultsQuoteAdapter()
        DemoQuoteData.seedIfNeeded(in: repository)
        _viewModel = StateObject(
            wrappedValue: QuotesViewModel(repository: repository)
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: viewModel,
                router: router
            )
        }
    }
}