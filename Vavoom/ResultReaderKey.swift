import Foundation
import Sharing

struct ResultReaderKey<Value: Sendable>: SharedReaderKey {

    let id = UUID()
    var result: Result<Value, any Error>

    func load(context: LoadContext<Value>, continuation: LoadContinuation<Value>) {
        continuation.resume(with: result.map(Optional.some))
    }

    func subscribe(context: LoadContext<Value>, subscriber: SharedSubscriber<Value>) -> SharedSubscription {
        .init {}
    }
}
