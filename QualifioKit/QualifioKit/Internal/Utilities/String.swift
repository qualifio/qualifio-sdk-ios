import Foundation

extension String {
    internal func toRegex() -> NSRegularExpression {
        do {
            return try NSRegularExpression(pattern: self)
        } catch {
            preconditionFailure("Illegal regular expression: \(self).")
        }
    }

    internal func matches(_ regex: NSRegularExpression) -> Bool {
        let range = NSRange(location: 0, length: utf16.count)
        return regex.firstMatch(in: self, options: [], range: range)?.range == range
    }
}
