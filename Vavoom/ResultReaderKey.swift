import Foundation
import Sharing
import Synchronization

final class ResultReaderKey<Value: Sendable>: SharedReaderKey {

    let id = UUID()
    let result: Result<Value, any Error>?
    let continuation = Mutex<LoadContinuation<Value>?>(nil)

    init(_ value: Value) {
        self.result = .success(value)
    }

    init(throwing error: any Error) {
        self.result = .failure(error)
    }

    init(result: Result<Value, any Error>? = nil) {
        self.result = result
    }

    func load(context: LoadContext<Value>, continuation: LoadContinuation<Value>) {
        if let result {
            continuation.resume(with: result.map(Optional.some))
        } else {
            self.continuation.withLock { $0 = continuation }
        }
    }

    func subscribe(context: LoadContext<Value>, subscriber: SharedSubscriber<Value>) -> SharedSubscription {
        .init {}
    }
}
