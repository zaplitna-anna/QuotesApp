import SwiftUI

struct ContentView: View {

    @ObservedObject var viewModel: QuotesViewModel
    @ObservedObject var router: AppRouter

    let apiService: any QuoteAPIService

    var body: some View {
        NavigationStack(path: $router.path) {

            QuotesListView(
                viewModel: viewModel,
                router: router
            )
            .navigationDestination(for: QuoteRoute.self) { route in

                switch route {

                case .details(let id):
                    QuoteDetailView(
                        quoteID: id,
                        viewModel: viewModel
                    )

                case .favorites:
                    FavoritesView(
                        viewModel: viewModel,
                        router: router
                    )

                case .onlineQuotes:
                    RemoteQuotesView(
                        service: apiService,
                        localViewModel: viewModel
                    )
                }
            }
        }
        .sheet(isPresented: $router.isShowingAddQuote) {
            AddQuoteView(
                viewModel: viewModel,
                router: router
            )
        }
    }
}

#Preview {
    ContentView(
        viewModel: QuotesViewModel(
            repository: QuoteCollection()
        ),
        router: AppRouter(),
        apiService: MockQuoteAPIService(mode: .empty)
    )
}
