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
    }

    @Test func duplicateNameQuote() {
        let quoteView = QuoteView(animeQuote: .init(ResultReaderKey<AnimeQuote?>(.onePiece)))

        #expect(quoteView.quote == "It doesn't matter who your parents were. Everyone is a child of the sea.")
        #expect(quoteView.quotee == "- Whitebeard")
        #expect(quoteView.source == "One Piece")
        #expect(quoteView.redactionReasons == [])
    }

    @Test func loadingQuote() {
        let quoteView = QuoteView(animeQuote: .init(ResultReaderKey<AnimeQuote?>()))

        #expect(quoteView.quote == "This is a long placeholder that is shown when the quote is loading and should go over a couple lines.")
        #expect(quoteView.quotee == "- Example Name")
        #expect(quoteView.source == "Example Name")
        #expect(quoteView.redactionReasons == .placeholder)
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
