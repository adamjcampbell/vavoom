import Foundation
import Sharing

let rawJSON = #"{"status":"success","data":{"content":"Some things can't be prevented. The last of which, is death. All we can do is live until the day we die. Control what we can... and fly free!","anime":{"id":451,"name":"Space Brothers","altName":"Uchuu Kyoudai"},"character":{"id":1880,"name":"Deneil Young"}}}"#

struct AnimeQuoteResponse: Decodable {
    var status: String
    var data: AnimeQuote
}

struct AnimeQuote: Decodable {
    var content: String
    var anime: Anime
    var character: Character
}

struct Anime: Decodable {
    var id: Int
    var name: String
    var altName: String?
}

struct Character: Decodable {
    var id: Int
    var name: String
}

struct AnimeQuoteKey: SharedReaderKey {
    let id = UUID()

    func load(context: Sharing.LoadContext<AnimeQuote?>, continuation: Sharing.LoadContinuation<AnimeQuote?>) {
        let response = try! JSONDecoder().decode(AnimeQuoteResponse.self, from: rawJSON.data(using: .utf8)!)
        continuation.resume(returning: response.data)
    }

    func subscribe(context: Sharing.LoadContext<AnimeQuote?>, subscriber: Sharing.SharedSubscriber<AnimeQuote?>) -> Sharing.SharedSubscription {
        SharedSubscription {}
    }
}

extension SharedReaderKey where Self == AnimeQuoteKey {
    static var animeQuote: Self {
        AnimeQuoteKey()
    }
}
