import Foundation

extension URL {
    internal func appendingQueryComponent(name: String, value: String) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        var queryItems = components.queryItems ?? []

        // Upsert the given query parameter
        if let index = queryItems.firstIndex(where: { $0.name == name }) {
            queryItems[index].value = value
        } else {
            queryItems.append(URLQueryItem(name: name, value: value))
        }

        // Update the query items.
        components.queryItems = queryItems

        // Explicitly encode "+" to align behaviour with Android & Web
        components.percentEncodedQuery = components.percentEncodedQuery?
            .replacingOccurrences(of: "+", with: "%2B")

        return components.url!
    }

    internal mutating func appendQueryComponent(name: String, value: String) {
        self = appendingQueryComponent(name: name, value: value)
    }
}
