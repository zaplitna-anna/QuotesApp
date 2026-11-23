import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: QuotesViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Лабораторна робота №2")
                    .font(.title2.bold())
                
                Text("MVVM, Патерни та SOLID")
                    .foregroundStyle(.secondary)

                Text(viewModel.demoOutput)
                    .font(.system(.body, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                Button(action: {
                    viewModel.runDemo()
                }) {
                    Text("Запустити сценарій")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.indigo)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView(viewModel: QuotesViewModel(storage: QuoteCollection()))
}