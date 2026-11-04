import Foundation

/// Errors thrown by the Qualifio SDK.
public enum QualifioError: Error, Sendable {
    /// Qualifio has not been configured.
    case notConfigured(message: String)

    /// No view controller was found to present the campaign from.
    case viewControllerNotFound(message: String)

    /// An argument, such as a blank campaign slug, is invalid.
    case invalidArgument(message: String)
}

extension QualifioError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notConfigured(let message),
             .viewControllerNotFound(let message),
             .invalidArgument(let message):
            return message
        }
    }
}
