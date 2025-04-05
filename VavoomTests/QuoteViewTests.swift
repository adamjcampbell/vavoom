import ConcurrencyExtras
import Dependencies
import DependenciesTestSupport
import Foundation
import SwiftUI
import Synchronization
import Testing
@testable import Vavoom

@Suite(
    .dependencies {
        $0.apiClient.getRandomQuote = { .spaceBrothers }
    }
)
struct QuoteViewTests {

    @Test func standardQuote() async {
        await withMainSerialExecutor {
            let quoteView = await QuoteView()

            await Task.yield()

            await #expect(quoteView.quote == "Some things can't be prevented. The last of which, is death. All we can do is live until the day we die. Control what we can... and fly free!")
            await #expect(quoteView.quotee == "- Deneil Young")
            await #expect(quoteView.source == "Space Brothers (Uchuu Kyoudai)")
            await #expect(quoteView.redactionReasons == [])
            await #expect(quoteView.errorConfiguration == nil)
        }
    }

    @Test(
        .dependencies {
            $0.apiClient.getRandomQuote = { .onePiece }
        }
    )
    func duplicateNameQuote() async {
        await withMainSerialExecutor {
            let quoteView = await QuoteView()

            await Task.yield()

            await #expect(quoteView.quote == "It doesn't matter who your parents were. Everyone is a child of the sea.")
            await #expect(quoteView.quotee == "- Whitebeard")
            await #expect(quoteView.source == "One Piece")
            await #expect(quoteView.redactionReasons == [])
            await #expect(quoteView.errorConfiguration == nil)
        }
    }

    @Test func loadingQuote() {
        let quoteView = QuoteView(animeQuote: .init(value: nil))

        #expect(quoteView.quote == "This is a long placeholder that is shown when the quote is loading and should go over a couple lines.")
        #expect(quoteView.quotee == "- Example Name")
        #expect(quoteView.source == "Example Name")
        #expect(quoteView.redactionReasons == .placeholder)
        #expect(quoteView.errorConfiguration == nil)
    }

    @Test(
        .dependencies {
            $0.apiClient.getRandomQuote = { throw NSError(domain: "Test", code: 0) }
        }
    )
    func errorQuote() async {
        await withMainSerialExecutor {
            let quoteView = await QuoteView()

            await Task.yield()

            await #expect(quoteView.quote == "This is a long placeholder that is shown when the quote is loading and should go over a couple lines.")
            await #expect(quoteView.quotee == "- Example Name")
            await #expect(quoteView.source == "Example Name")
            await #expect(quoteView.redactionReasons == .placeholder)
            await #expect(quoteView.errorConfiguration == .init(title: "Failed to load quote", systemImageName: "text.quote", description: "Pull to refresh to try again"))
        }
    }

    @Test func refreshingQuote() async throws {
        let mutex = Mutex(Optional<CheckedContinuation<AnimeQuote, any Error>>.none)

        try await withDependencies {
            $0.apiClient.getRandomQuote = {
                try await withCheckedThrowingContinuation { c in mutex.withLock { $0 = c } }
            }
        } operation: {
            try await withMainSerialExecutor {
                let quoteView = await QuoteView()
                await Task.yield()

                mutex.withLock { $0?.resume(returning: .spaceBrothers) }
                await Task.yield()

                await #expect(quoteView.quote == "Some things can't be prevented. The last of which, is death. All we can do is live until the day we die. Control what we can... and fly free!")
                await #expect(quoteView.quotee == "- Deneil Young")
                await #expect(quoteView.source == "Space Brothers (Uchuu Kyoudai)")
                await #expect(quoteView.redactionReasons == [])
                await #expect(quoteView.errorConfiguration == nil)

                let refreshTask = Task { try await quoteView.refresh(.animeQuote) }
                await Task.megaYield()

                mutex.withLock { $0?.resume(returning: .onePiece) }
                try await refreshTask.value

                await #expect(quoteView.quote == "It doesn't matter who your parents were. Everyone is a child of the sea.")
                await #expect(quoteView.quotee == "- Whitebeard")
                await #expect(quoteView.source == "One Piece")
                await #expect(quoteView.redactionReasons == [])
                await #expect(quoteView.errorConfiguration == nil)
            }
        }
    }

}

extension AnimeQuote {
    private static let decoder = JSONDecoder()

    private static func decode(json: String) -> Self {
        return try! decoder.decode(AnimeQuoteResponse.self, from: json.data(using: .utf8)!).data
    }

    static var spaceBrothers: Self {
        decode(
            json: #"{"status":"success","data":{"content":"Some things can't be prevented. The last of which, is death. All we can do is live until the day we die. Control what we can... and fly free!","anime":{"id":451,"name":"Space Brothers","altName":"Uchuu Kyoudai"},"character":{"id":1880,"name":"Deneil Young"}}}"#
        )
    }

    static var onePiece: Self {
        decode(
            json: #"{"status":"success","data":{"content":"It doesn't matter who your parents were. Everyone is a child of the sea.","anime":{"id":229,"name":"One Piece","altName":"One Piece"},"character":{"id":1813,"name":"Whitebeard"}}}"#
        )
    }
}
