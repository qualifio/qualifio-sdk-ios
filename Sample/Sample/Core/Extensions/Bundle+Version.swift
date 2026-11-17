import Foundation

extension Bundle {
    internal var applicationVersion: String {
        if let bundleShortVersion = self.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            return bundleShortVersion
        } else if let bundleVersion = self.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            return bundleVersion
        }

        return ""
    }
}
