import Dependencies
import DependenciesMacros
import Foundation

@DependencyClient
struct APIClient {
    var getRandomQuote: () async throws -> AnimeQuote
}

extension APIClient: DependencyKey {
    enum Error: Swift.Error {
        case quoteNotFound
    }

    static var liveValue: Self {
        .init {
            let request = URLRequest(url: .init(string: "https://yurippe.vercel.app/api/quotes?random=1")!)
            let data = try await URLSession.shared.data(for: request).0
            let response = try JSONDecoder().decode([AnimeQuote].self, from: data)

            if let quote = response.first {
                return quote
            } else {
                throw Error.quoteNotFound
            }
        }
    }
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}
