import Foundation
import Combine

internal class ConfigurationViewModel: ObservableObject {
    internal func updateConfiguration(domain: String, secret: String?) {
        Preferences.standard.domain = domain

        if let secret {
            Preferences.standard.secureTokenSecret = secret
            Preferences.standard.useSecureToken = true
        }

        Preferences.standard.configurationFinished = true
    }

    internal func validateDomain(_ domain: String) -> Bool {
        guard !domain.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }

        let normalized = normalizeDomain(domain)

        guard let components = URLComponents(string: normalized) else {
            return false
        }

        return components.scheme != nil && components.host != nil && components.query == nil
    }

    private func normalizeDomain(_ domain: String) -> String {
        if !domain.hasPrefix("https://") && !domain.hasPrefix("http://") {
            return "https://\(domain)"
        }
        return domain
    }
}
