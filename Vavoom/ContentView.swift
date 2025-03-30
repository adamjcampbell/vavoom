import Sharing
import SwiftUI

struct ContentView: View {
    @SharedReader(.animeQuote) var animeQuote

    var animeName: String {
        let name = animeQuote?.anime.name ?? "Example Name"
        return (animeQuote?.anime.altName).map { "\(name) (\($0))" } ?? name
    }
    var quote: String {
        animeQuote?.content ??
            "This is a long placeholder that is shown when the quote is loading and should go over a couple lines."
    }
    var quotee: String {
        let quotee = animeQuote?.character.name ?? "Example Name"
        return "- \(quotee)"
    }
    var redactionReasons: RedactionReasons { animeQuote == nil ? .placeholder : [] }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: "quote.opening")
                    .font(.title)
                Text(quote)
                    .font(.title)
                Text(quotee)
                    .font(.title2)
                Text(animeName)
                    .font(.title3)
            }
            .padding(32)
            .redacted(reason: redactionReasons)
            .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
            .padding()
        }
        .defaultScrollAnchor(.center)
    }
}

#Preview {
    ContentView()
}
