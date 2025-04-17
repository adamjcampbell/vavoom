import Foundation

#if DEBUG
extension AnimeQuote {
    private static let decoder = JSONDecoder()

    private static func decode(json: String) -> Self {
        return try! decoder.decode(AnimeQuote.self, from: json.data(using: .utf8)!)
    }

    static var blackLagoon: Self {
        decode(json: #"{"_id":"6697e43fe3adf3ea5a01da38","character":"Okajima Rokuro","show":"Black Lagoon","quote":"I'm no saint. A sense of duty, a sense of righteousness - they're just nuisances in life."}"#)
    }

    static var serialExperimentsLain: Self {
        decode(json: #"{"_id":"6697e442e3adf3ea5a01daa6","character":"Lain Iwakura","show":"Serial Experiments Lain","quote":"What isn't remembered never happened."}"#)
    }
}
#endif
