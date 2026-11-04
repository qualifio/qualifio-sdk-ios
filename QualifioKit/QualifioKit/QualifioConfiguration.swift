import Foundation

private let HOST_REGEX = "^(https?://)?(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])(:[0-9]{1,5})?$".toRegex()

public struct QualifioConfiguration: Codable {
    public let domain: String

    public init(domain: String) {
        self.domain = domain
    }

    internal var isValid: Bool {
        guard domain.matches(HOST_REGEX) else {
            logger.debug("Invalid domain value.")
            return false
        }

        return true
    }

    internal var host: String {
        if !domain.hasPrefix("https://") && !domain.hasPrefix("http://") {
            return "https://\(domain)"
        }

        return domain
    }

    private enum CodingKeys: String, CodingKey {
        case domain = "domain"
    }
}
