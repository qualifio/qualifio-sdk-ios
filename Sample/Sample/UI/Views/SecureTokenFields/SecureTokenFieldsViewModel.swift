import Combine
import Foundation

internal final class SecureTokenFieldsViewModel: ObservableObject {
    internal func addSecureTokenField(_ key: String, _ value: String) {
        Preferences.standard.secureTokenFields[key.trimmingCharacters(in: .whitespacesAndNewlines)] = value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    internal func deleteSecureTokenField(_ key: String) {
        Preferences.standard.secureTokenFields.removeValue(forKey: key)
    }
}
