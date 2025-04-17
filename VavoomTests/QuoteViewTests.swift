import ConcurrencyExtras
import Dependencies
import DependenciesTestSupport
import Foundation
import SwiftUI
import Synchronization
import Testing
@testable import Vavoom

@MainActor
@Suite(
    .dependencies {
        $0.apiClient.getRandomQuote = {
            await Task.yield()
            return .blackLagoon
        }
    }
)
struct QuoteViewTests {
    @Test func loadingQuote() {
        withMainSerialExecutor {
            let quoteView = QuoteView()

            #expect(quoteView.$animeQuote.isLoading == true)
            #expect(quoteView.quote == "This is a long placeholder that is shown when the quote is loading and should go over a couple lines.")
            #expect(quoteView.quotee == "- Example Name")
            #expect(quoteView.source == "Example Name")
            #expect(quoteView.redactionReasons == .placeholder)
            #expect(quoteView.errorConfiguration == nil)
        }
    }

    @Test func loadedQuote() async {
        await withMainSerialExecutor {
            let quoteView = QuoteView()

            // Ensure operations are completed
            await Task.megaYield()

            #expect(quoteView.quote == "I'm no saint. A sense of duty, a sense of righteousness - they're just nuisances in life.")
            #expect(quoteView.quotee == "- Okajima Rokuro")
            #expect(quoteView.source == "Black Lagoon")
            #expect(quoteView.redactionReasons == [])
            #expect(quoteView.errorConfiguration == nil)
        }
    }

    @Test(
        .dependencies {
            $0.apiClient.getRandomQuote = { throw NSError(domain: "Test", code: 0) }
        }
    )
    func errorQuote() async {
        await withMainSerialExecutor {
            let quoteView = QuoteView()

            // Ensure operations are completed
            await Task.megaYield()

            #expect(quoteView.quote == "This is a long placeholder that is shown when the quote is loading and should go over a couple lines.")
            #expect(quoteView.quotee == "- Example Name")
            #expect(quoteView.source == "Example Name")
            #expect(quoteView.redactionReasons == .placeholder)
            #expect(quoteView.errorConfiguration == .init(title: "Failed to load quote", systemImageName: "text.quote", description: "Pull to refresh to try again"))
        }
    }

    @Test func loadAndRefreshQuote() async throws {
        try await withMainSerialExecutor {
            let quoteView = QuoteView()

            #expect(quoteView.quote == "This is a long placeholder that is shown when the quote is loading and should go over a couple lines.")
            #expect(quoteView.quotee == "- Example Name")
            #expect(quoteView.source == "Example Name")
            #expect(quoteView.redactionReasons == .placeholder)
            #expect(quoteView.errorConfiguration == nil)

            // Ensure operations are completed
            await Task.megaYield()

            #expect(quoteView.quote == "I'm no saint. A sense of duty, a sense of righteousness - they're just nuisances in life.")
            #expect(quoteView.quotee == "- Okajima Rokuro")
            #expect(quoteView.source == "Black Lagoon")
            #expect(quoteView.redactionReasons == [])
            #expect(quoteView.errorConfiguration == nil)

            try await withDependencies {
                $0.apiClient.getRandomQuote = { .serialExperimentsLain }
            } operation: {
                try await quoteView.refresh()

                #expect(quoteView.quote == "What isn't remembered never happened.")
                #expect(quoteView.quotee == "- Lain Iwakura")
                #expect(quoteView.source == "Serial Experiments Lain")
                #expect(quoteView.redactionReasons == [])
                #expect(quoteView.errorConfiguration == nil)
            }
        }
    }
}
