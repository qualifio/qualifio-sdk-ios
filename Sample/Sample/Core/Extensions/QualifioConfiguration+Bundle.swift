import QualifioKit
import Foundation

extension QualifioConfiguration {
    internal static func loadFromBundle(
        filename: String = "QualifioServices",
        bundle: Bundle = .main
    ) -> QualifioConfiguration {
        guard let url = bundle.url(forResource: filename, withExtension: "plist") else {
            fatalError("QualifioServices.plist not found.")
        }

        do {
            let data = try Data(contentsOf: url)
            return try PropertyListDecoder().decode(QualifioConfiguration.self, from: data)
        } catch {
            fatalError("Could not parse the QualifioServices.plist file. Please check the contents are valid.")
        }
    }
}
