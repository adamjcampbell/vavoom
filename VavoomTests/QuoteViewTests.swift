import Foundation
import SwiftUI
import Testing
@testable import Vavoom

struct QuoteViewTests {

    @Test func standardQuote() {
        let quoteView = QuoteView(animeQuote: .init(ResultReaderKey<AnimeQuote?>(.spaceBrothers)))

        #expect(quoteView.quote == "Some things can't be prevented. The last of which, is death. All we can do is live until the day we die. Control what we can... and fly free!")
        #expect(quoteView.quotee == "- Deneil Young")
        #expect(quoteView.source == "Space Brothers (Uchuu Kyoudai)")
        #expect(quoteView.redactionReasons == [])
        #expect(quoteView.errorConfiguration == nil)
    }

    @Test func duplicateNameQuote() {
        let quoteView = QuoteView(animeQuote: .init(ResultReaderKey<AnimeQuote?>(.onePiece)))

        #expect(quoteView.quote == "It doesn't matter who your parents were. Everyone is a child of the sea.")
        #expect(quoteView.quotee == "- Whitebeard")
        #expect(quoteView.source == "One Piece")
        #expect(quoteView.redactionReasons == [])
        #expect(quoteView.errorConfiguration == nil)
    }

    @Test func loadingQuote() {
        let quoteView = QuoteView(animeQuote: .init(ResultReaderKey<AnimeQuote?>()))

        #expect(quoteView.quote == "This is a long placeholder that is shown when the quote is loading and should go over a couple lines.")
        #expect(quoteView.quotee == "- Example Name")
        #expect(quoteView.source == "Example Name")
        #expect(quoteView.redactionReasons == .placeholder)
        #expect(quoteView.errorConfiguration == nil)
    }

    @Test func errorQuote() {
        // Sharing internally reports issues so we much wrap this with `withKnownIssue`s unfortunately
        // There is an open discussion here if you feel it should not be so: https://github.com/pointfreeco/swift-sharing/discussions/143
        withKnownIssue {
            let quoteView = QuoteView(animeQuote: .init(ResultReaderKey<AnimeQuote?>(throwing: NSError(domain: "", code: 0))))

            #expect(quoteView.quote == "This is a long placeholder that is shown when the quote is loading and should go over a couple lines.")
            #expect(quoteView.quotee == "- Example Name")
            #expect(quoteView.source == "Example Name")
            #expect(quoteView.redactionReasons == .placeholder)
            #expect(quoteView.errorConfiguration == .init(title: "Failed to load quote", systemImageName: "text.quote", description: "Pull to refresh to try again"))
        }
    }

    @Test func refreshingQuote() async throws {
        let quoteView = QuoteView(animeQuote: .init(ResultReaderKey<AnimeQuote?>(.spaceBrothers)))

        await #expect(quoteView.quote == "Some things can't be prevented. The last of which, is death. All we can do is live until the day we die. Control what we can... and fly free!")
        await #expect(quoteView.quotee == "- Deneil Young")
        await #expect(quoteView.source == "Space Brothers (Uchuu Kyoudai)")
        await #expect(quoteView.redactionReasons == [])
        await #expect(quoteView.errorConfiguration == nil)

        try await quoteView.refresh(ResultReaderKey<AnimeQuote?>(.onePiece))

        await #expect(quoteView.quote == "It doesn't matter who your parents were. Everyone is a child of the sea.")
        await #expect(quoteView.quotee == "- Whitebeard")
        await #expect(quoteView.source == "One Piece")
        await #expect(quoteView.redactionReasons == [])
        await #expect(quoteView.errorConfiguration == nil)
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
