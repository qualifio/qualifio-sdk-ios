import Foundation

internal enum QualifioError: Error {
    case notConfigured(message: String)
    case viewControllerNotFound(message: String)
    case invalidArgument(message: String)
    case timeout(message: String)
}

extension QualifioError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .notConfigured(let message),
             .viewControllerNotFound(let message),
             .invalidArgument(let message),
             .timeout(let message):
            return message
        }
    }
}
