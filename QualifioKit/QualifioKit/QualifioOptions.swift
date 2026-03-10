import Foundation

public struct QualifioOptions: Decodable, Sendable {
    public let debugLoggingEnabled: Bool
    public let autoConfigEnabled: Bool

    public init(debugLoggingEnabled: Bool = false, autoConfigEnabled: Bool = true) {
        self.debugLoggingEnabled = debugLoggingEnabled
        self.autoConfigEnabled = autoConfigEnabled
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.debugLoggingEnabled = try container.decodeIfPresent(Bool.self, forKey: .debugLoggingEnabled) ?? false
        self.autoConfigEnabled = try container.decodeIfPresent(Bool.self, forKey: .autoConfigEnabled) ?? true
    }

    internal enum CodingKeys: String, CodingKey {
        case debugLoggingEnabled = "DEBUG_LOGGING_ENABLED"
        case autoConfigEnabled = "AUTO_CONFIG_ENABLED"
    }
}
