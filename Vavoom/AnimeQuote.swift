import Foundation
import Sharing
import os

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
    var altName: String
}

struct Character: Decodable {
    var id: Int
    var name: String
}

struct AnimeQuoteKey: SharedReaderKey {
    let id = UUID()
    let loadTask = OSAllocatedUnfairLock<Task<Void, Never>?>(initialState: nil)

    func load(context: Sharing.LoadContext<AnimeQuote?>, continuation: Sharing.LoadContinuation<AnimeQuote?>) {
        let request = URLRequest(url: .init(string: "https://animechan.io/api/v1/quotes/random")!)

        loadTask.withLock { task in
            task?.cancel()
            task = Task {
                do {
                    let data = try await URLSession.shared.data(for: request).0
                    let quote = try JSONDecoder().decode(AnimeQuoteResponse.self, from: data).data
                    continuation.resume(returning: quote)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
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
