import Foundation
import SafariServices

@MainActor
public protocol QualifioDelegate: AnyObject {
    func qualifio(
        _ qualifio: Qualifio,
        generateSecureTokenFor url: URL
    ) async throws -> String?

    func qualifio(
        _ qualifio: Qualifio,
        customizeSafariViewController viewController: SFSafariViewController
    )
}

extension QualifioDelegate {
    public func qualifio(
        _ qualifio: Qualifio,
        generateSecureTokenFor url: URL,
        _ completion: @escaping QualifioCallback<String?>
    ) {
        completion(.success(nil))
    }

    public func qualifio(
        _ qualifio: Qualifio,
        generateSecureTokenFor url: URL
    ) async throws -> String? {
        return try await withCheckedThrowingContinuation { continuation in
            self.qualifio(qualifio, generateSecureTokenFor: url) { result in
                continuation.resume(with: result)
            }
        }
    }

    public func qualifio(
        _ qualifio: Qualifio,
        customizeSafariViewController viewController: SFSafariViewController
    ) {
        // No customisations by default.
    }
}
