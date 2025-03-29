import Sharing
import SwiftUI

struct ContentView: View {
    @SharedReader(.animeQuote) var animeQuote

    var animeName: String {
        let name = animeQuote?.anime.name ?? "Example Name"
        let nameLine = (animeQuote?.anime.altName).map { "\(name) (\($0))" } ?? name
        return "From: \(nameLine)"
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
        VStack(alignment: .leading, spacing: 0) {
            Text(quote)
                .padding(.bottom, 4)
            Text(quotee)
                .font(.callout)
                .padding(.bottom)
            Text(animeName).font(.footnote)
        }
        .padding()
        .redacted(reason: redactionReasons)
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: 10))
        .padding()
    }
}

#Preview {
    ContentView()
}
