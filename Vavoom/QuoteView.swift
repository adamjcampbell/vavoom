import Sharing
import SwiftUI

struct QuoteView: View {
    @SharedReader(.animeQuote) var animeQuote

    var quote: String {
        animeQuote?.content ??
            "This is a long placeholder that is shown when the quote is loading and should go over a couple lines."
    }
    var quotee: String {
        let quotee = animeQuote?.character.name ?? "Example Name"
        return "- \(quotee)"
    }
    var source: String {
        let name = animeQuote?.anime.name ?? "Example Name"
        let dualName = (animeQuote?.anime.altName).flatMap { altName in
            altName != name ? "\(name) (\(altName))" : nil
        }
        return dualName ?? name
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
                Text(source)
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
    let rawJSON = #"{"status":"success","data":{"content":"Some things can't be prevented. The last of which, is death. All we can do is live until the day we die. Control what we can... and fly free!","anime":{"id":451,"name":"Space Brothers","altName":"Uchuu Kyoudai"},"character":{"id":1880,"name":"Deneil Young"}}}"#
    let quote = try! JSONDecoder().decode(AnimeQuoteResponse.self, from: rawJSON.data(using: .utf8)!).data
    QuoteView(animeQuote: .init(ResultReaderKey<AnimeQuote?>(result: .success(quote))))
}
