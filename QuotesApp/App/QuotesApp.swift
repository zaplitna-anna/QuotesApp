import SwiftUI

@main
struct QuotesApp: App {

    @StateObject private var viewModel: QuotesViewModel
    @StateObject private var router = AppRouter()

    private let apiService: any QuoteAPIService =
        URLSessionQuoteAPIService()

    init() {
        let repository: any QuoteRepository =
            UserDefaultsQuoteAdapter()

        DemoQuoteData.seedIfNeeded(in: repository)

        _viewModel = StateObject(
            wrappedValue: QuotesViewModel(
                repository: repository
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
                viewModel: viewModel,
                router: router,
                apiService: apiService
            )
        }
    }
}
