import Foundation

internal enum QualifioError: Error {
    case notConfigured(message: String)
    case viewControllerNotFound(message: String)
    case invalidArgument(message: String)
}
