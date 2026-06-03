internal func withTimeout<T: Sendable>(
    seconds: Int,
    operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    try await withThrowingTaskGroup(of: T.self) { group in
        group.addTask {
            try await operation()
        }

        group.addTask {
            try await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
            throw QualifioError.timeout(message: "Timed out waiting for \(seconds) seconds.")
        }

        guard let result = try await group.next() else {
            group.cancelAll()
            throw CancellationError()
        }

        group.cancelAll()
        return result
    }
}
