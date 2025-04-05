import Dependencies
import Foundation
import Sharing
import Synchronization

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

final class AnimeQuoteKey: SharedReaderKey {
    let id = UUID()
    let loadTask = Mutex<Task<Void, Never>?>(nil)

    func load(context: Sharing.LoadContext<AnimeQuote?>, continuation: Sharing.LoadContinuation<AnimeQuote?>) {
        @Dependency(\.apiClient) var apiClient

        loadTask.withLock { task in
            task?.cancel()
            task = Task {
                do {
                    continuation.resume(returning: try await apiClient.getRandomQuote())
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
