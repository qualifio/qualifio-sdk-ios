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

    /// Uses the same rule as the SDK (`QualifioConfiguration.isValid`): an optional
    /// http(s) scheme, a hostname and an optional port. Anything the SDK rejects would
    /// make `Qualifio.shared.configure` stop the app with a `fatalError`.
    internal func validateDomain(_ domain: String) -> Bool {
        domain.matches(domainRegex)
    }
}

private let domainRegex = "^(https?://)?(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])(:[0-9]{1,5})?$".toRegex()
