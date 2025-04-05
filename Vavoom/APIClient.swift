import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct APIClient {
    var getRandomQuote: () async throws -> AnimeQuote
}

extension APIClient: DependencyKey {
    static var liveValue: Self {
        .init {
            let request = URLRequest(url: .init(string: "https://animechan.io/api/v1/quotes/random")!)
            let data = try await URLSession.shared.data(for: request).0
            let quote = try JSONDecoder().decode(AnimeQuoteResponse.self, from: data).data
            return quote
        }
    }
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
