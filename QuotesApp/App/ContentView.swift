import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "terminal.fill")
                .font(.system(size: 60))
                .foregroundStyle(.indigo)
            
            Text("Практична робота №1")
                .font(.title2.bold())
            
            Text("Уся робота програми виводиться в консоль Xcode")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .onAppear {
            QuoteDemo.run()
        }
    }
}

#Preview {
    ContentView()
}
