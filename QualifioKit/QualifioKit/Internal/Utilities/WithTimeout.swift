import Foundation

internal func withTimeout<T: Sendable>(
    milliseconds: Int,
    operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }

        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(milliseconds) * 1_000_000)
            throw QualifioTimeoutError(milliseconds: milliseconds)
        }

        guard let result = try await group.next() else {
            group.cancelAll()
            throw CancellationError()
        }

        group.cancelAll()
        return result
    }
}

internal struct QualifioTimeoutError: LocalizedError {
    let milliseconds: Int

    var errorDescription: String? {
        "Timed out waiting for \(milliseconds) milliseconds."
    }
}
