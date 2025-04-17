import Dependencies
import Sharing
import SwiftUI

struct QuoteView: View {
    @State.SharedReader(.animeQuote) var animeQuote

    var quote: String {
        animeQuote?.quote ??
            "This is a long placeholder that is shown when the quote is loading and should go over a couple lines."
    }
    var quotee: String {
        let quotee = animeQuote?.character ?? "Example Name"
        return "- \(quotee)"
    }
    var source: String {
        animeQuote?.show ?? "Example Name"
    }
    var redactionReasons: RedactionReasons { animeQuote == nil ? .placeholder : [] }
    var errorConfiguration: ErrorConfiguration? {
        if $animeQuote.loadError != nil {
            ErrorConfiguration(
                title: "Failed to load quote",
                systemImageName: "text.quote",
                description: "Pull to refresh to try again"
            )
        } else {
            nil
        }
    }

    struct ErrorConfiguration: Equatable {
        var title: String
        var systemImageName: String
        var description: String
    }

    var body: some View {
        ScrollView {
            if let errorConfiguration {
                ContentUnavailableView(
                    errorConfiguration.title,
                    systemImage: errorConfiguration.systemImageName,
                    description: Text(errorConfiguration.description)
                )
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Image(systemName: "quote.opening")
                        .font(.title)
                        .unredacted()
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
        }
        .defaultScrollAnchor(.center)
        .refreshable {
            Task { try await refresh(.animeQuote) }
        }
    }

    func refresh<Key>(_ key: Key) async throws where Key: SharedReaderKey, Key.Value == AnimeQuote? {
        try await $animeQuote.load(key)
    }
}

#if DEBUG
#Preview("Loaded") {
    let _ = prepareDependencies {
        $0.apiClient.getRandomQuote = { .blackLagoon }
    }

    QuoteView()
}

#Preview("Error") {
    let _ = prepareDependencies {
        $0.apiClient.getRandomQuote = { throw APIClient.Error.quoteNotFound }
    }

    QuoteView()
}

#Preview("Loading") {
    let _ = prepareDependencies {
        $0.apiClient.getRandomQuote = { try await Task.never() }
    }

    QuoteView()
}
#endif
