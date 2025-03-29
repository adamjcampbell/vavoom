import Sharing
import SwiftUI

struct ContentView: View {
    @SharedReader(.animeQuote) var animeQuote

    var quote: String {
        animeQuote?.content ?? "This is a long placeholder that is shown when the quote is loading and should go over a couple lines."
    }
    var redactionReasons: RedactionReasons { animeQuote == nil ? .placeholder : [] }

    var body: some View {
        VStack {
            Text(quote)
        }
        .padding()
        .redacted(reason: redactionReasons)
    }
}

#Preview {
    ContentView()
}
