import Foundation

public struct QualifioConfiguration: Codable {
    public let domain: String

    public init(domain: String) {
        self.domain = domain
    }

    internal var isValid: Bool {
        guard let components = URLComponents(string: host),
              components.scheme != nil,
              components.host != nil,
              components.query == nil
        else {
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
