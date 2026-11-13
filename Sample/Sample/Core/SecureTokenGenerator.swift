import CryptoKit
import Foundation

internal enum SecureTokenGenerator {
    private static let issuer = "Qualifio"
    private static let campaignIdField = "campaignId"

    internal static func generate(secret: String, subject: String, fields: [String: String]) throws -> String {
        var payload: [String: Any] = [
            "sub": subject,
            "iss": issuer,
            "iat": Int(Date().timeIntervalSince1970),
        ]

        if let campaignId = fields[campaignIdField] {
            payload[campaignIdField] = campaignId
        }

        let formFields = fields.filter { $0.key != campaignIdField }
        if !formFields.isEmpty {
            payload["form"] = formFields
        }

        return try sign(payload: payload, secret: secret)
    }

    private static func sign(payload: [String: Any], secret: String) throws -> String {
        let header: [String: Any] = ["alg": "HS256", "typ": "JWT"]

        let encodedHeader = try base64URLEncode(json: header)
        let encodedPayload = try base64URLEncode(json: payload)
        let signingInput = "\(encodedHeader).\(encodedPayload)"

        let key = SymmetricKey(data: Data(secret.utf8))
        let signature = HMAC<SHA256>.authenticationCode(for: Data(signingInput.utf8), using: key)

        return "\(signingInput).\(base64URLEncode(Data(signature)))"
    }

    private static func base64URLEncode(json: [String: Any]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: json, options: [.sortedKeys, .withoutEscapingSlashes])
        return base64URLEncode(data)
    }

    private static func base64URLEncode(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
