import Combine
import Foundation
import OSLog

private enum Keys {
    static let configurationFinished = "configuration_finished"
    static let domain = "configuration_domain"
    static let useSecureToken = "use_secure_token"
    static let showCampaignAtLaunch = "show_campaign_at_launch"
    static let secureTokenAlgorithm = "secure_token_algorithm"
    static let secureTokenSecret = "secure_token_secret"
    static let secureTokenSubject = "secure_token_subject"
    static let secureTokenFields = "secure_token_fields"
}

internal final class Preferences {
    internal static let standard = Preferences(userDefaults: .standard)

    fileprivate let userDefaults: UserDefaults

    /// Sends through the changed key path whenever a change occurs.
    internal var preferencesChangedSubject = PassthroughSubject<AnyKeyPath, Never>()

    internal init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }

    // MARK: Stored preferences

    @UserDefault(Keys.configurationFinished)
    internal var configurationFinished: Bool = false

    @UserDefault(Keys.domain)
    internal var domain: String? = nil

    @UserDefault(Keys.useSecureToken)
    internal var useSecureToken: Bool = false

    @UserDefault(Keys.showCampaignAtLaunch)
    internal var showCampaignAtLaunch: Bool = false

    @UserDefault(Keys.secureTokenAlgorithm)
    internal var secureTokenAlgorithm: String = "HS256"

    @UserDefault(Keys.secureTokenSecret)
    internal var secureTokenSecret: String = ""

    @UserDefault(Keys.secureTokenSubject)
    internal var secureTokenSubject: String = "1234"

    @CodableUserDefault(Keys.secureTokenFields)
    internal var secureTokenFields: [String: String] = [:]
}

@propertyWrapper
internal struct UserDefault<Value> {
    internal let key: String
    internal let defaultValue: Value

    internal var wrappedValue: Value {
        get { fatalError("Wrapped value should not be used.") }
        set { fatalError("Wrapped value should not be used.") }
    }

    internal init(wrappedValue: Value, _ key: String) {
        self.defaultValue = wrappedValue
        self.key = key
    }

    public static subscript(
        _enclosingInstance instance: Preferences,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Preferences, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<Preferences, Self>
    ) -> Value {
        get {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            let defaultValue = instance[keyPath: storageKeyPath].defaultValue
            return container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            container.set(newValue, forKey: key)
            instance.preferencesChangedSubject.send(wrappedKeyPath)
        }
    }
}

@propertyWrapper
internal struct CodableUserDefault<Value: Codable> {
    internal let key: String
    internal let defaultValue: Value

    internal var wrappedValue: Value {
        get { fatalError("Wrapped value should not be used.") }
        set { fatalError("Wrapped value should not be used.") }
    }

    internal init(wrappedValue: Value, _ key: String) {
        self.defaultValue = wrappedValue
        self.key = key
    }

    public static subscript(
        _enclosingInstance instance: Preferences,
        wrapped wrappedKeyPath: ReferenceWritableKeyPath<Preferences, Value>,
        storage storageKeyPath: ReferenceWritableKeyPath<Preferences, Self>
    ) -> Value {
        get {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key
            let defaultValue = instance[keyPath: storageKeyPath].defaultValue

            do {
                if let encoded = container.data(forKey: key) {
                    let decoder = JSONDecoder()
                    return try decoder.decode(Value.self, from: encoded)
                }

                return defaultValue
            } catch {
                Logger.main.warning("Failed to decode value for '\(key)'.")
                return defaultValue
            }
        }
        set {
            let container = instance.userDefaults
            let key = instance[keyPath: storageKeyPath].key

            do {
                let encoder = JSONEncoder()
                let encoded = try encoder.encode(newValue)
                container.set(encoded, forKey: key)
                instance.preferencesChangedSubject.send(wrappedKeyPath)
            } catch {
                Logger.main.warning("Failed to encode value for '\(key)'.")
            }
        }
    }
}
