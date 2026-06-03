import Foundation

public struct QualifioOptions: Decodable, Sendable {
    public static let DEFAULT_DEBUG_LOGGING_ENABLED = false
    public static let DEFAULT_AUTO_CONFIG_ENABLED = true
    public static let DEFAULT_SECURE_TOKEN_GENERATOR_TIMEOUT_MILLISECONDS: Int = 30_000

    public let debugLoggingEnabled: Bool
    public let autoConfigEnabled: Bool
    public let secureTokenGeneratorTimeoutMilliseconds: Int

    public init(
        debugLoggingEnabled: Bool = DEFAULT_DEBUG_LOGGING_ENABLED,
        autoConfigEnabled: Bool = DEFAULT_AUTO_CONFIG_ENABLED,
        secureTokenGeneratorTimeoutMilliseconds: Int = DEFAULT_SECURE_TOKEN_GENERATOR_TIMEOUT_MILLISECONDS
    ) {
        self.debugLoggingEnabled = debugLoggingEnabled
        self.autoConfigEnabled = autoConfigEnabled
        self.secureTokenGeneratorTimeoutMilliseconds = secureTokenGeneratorTimeoutMilliseconds
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.debugLoggingEnabled = try container.decodeIfPresent(Bool.self, forKey: .debugLoggingEnabled) ?? QualifioOptions.DEFAULT_DEBUG_LOGGING_ENABLED
        self.autoConfigEnabled = try container.decodeIfPresent(Bool.self, forKey: .autoConfigEnabled) ?? QualifioOptions.DEFAULT_AUTO_CONFIG_ENABLED
        self.secureTokenGeneratorTimeoutMilliseconds = try container.decodeIfPresent(Int.self, forKey: .secureTokenGeneratorTimeoutMilliseconds) ?? QualifioOptions.DEFAULT_SECURE_TOKEN_GENERATOR_TIMEOUT_MILLISECONDS
    }

    internal enum CodingKeys: String, CodingKey {
        case debugLoggingEnabled = "DEBUG_LOGGING_ENABLED"
        case autoConfigEnabled = "AUTO_CONFIG_ENABLED"
        case secureTokenGeneratorTimeoutMilliseconds = "SECURE_TOKEN_GENERATOR_TIMEOUT_MILLISECONDS"
    }
}
