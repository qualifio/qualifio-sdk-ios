import Foundation
import os

public final class QualifioLogger: Sendable {

    public init(subsystem: String = "com.qualifio", category: String = "Qualifio", labelIgnoreList: [String] = []) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.labelIgnoreList = labelIgnoreList
    }

    public nonisolated(unsafe) var hasDebugLoggingEnabled: Bool = false

    private let labelIgnoreList: [String]
    private let logger: Logger

    public func debug(_ message: String, error: Error? = nil, file: String = #file) {
        log(level: .debug, message: message, error: error, file: file)
    }

    public func info(_ message: String, error: Error? = nil, file: String = #file) {
        log(level: .info, message: message, error: error, file: file)
    }

    public func warning(_ message: String, error: Error? = nil, file: String = #file) {
        log(level: .warning, message: message, error: error, file: file)
    }

    public func error(_ message: String, error: Error? = nil, file: String = #file) {
        log(level: .error, message: message, error: error, file: file)
    }

    private func log(level: Level, message: String, error: Error?, file: String = #file) {
        let label: String

        if
            let fullFileName = URL(fileURLWithPath: file).pathComponents.last,
            let fileName = fullFileName.split(separator: ".").first
        {
            label = String(fileName)
        } else {
            label = file
        }

        log(level: level, label: label, message: message, error: error)
    }

    private func log(level: Level, label: String?, message: String, error: Error?) {
        guard level != .debug || hasDebugLoggingEnabled else {
            return
        }

        var combined: String
        if let label = label, !labelIgnoreList.contains(label), hasDebugLoggingEnabled {
            combined = "[\(label)] \(message)"
        } else {
            combined = message
        }

        if let error = error {
            if hasDebugLoggingEnabled {
                combined = "\(combined)\n\(error)"
            } else {
                combined = "\(combined) \(error.localizedDescription)"
            }
        }


        logger.log(level: level.toOSLogType(), "\(combined, privacy: .public)")
    }
}

extension QualifioLogger {
    internal enum Level: String {
        case debug
        case info
        case warning
        case error
    }
}

extension QualifioLogger.Level {
    internal func toOSLogType() -> OSLogType {
        switch self {
        case .debug, .info:
            return .default
        case .warning, .error:
            return .error
        }
    }
}
