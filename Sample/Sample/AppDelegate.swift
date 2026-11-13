import OSLog
import UIKit
import QualifioKit
import SafariServices

internal class AppDelegate: NSObject, UIApplicationDelegate {
    private static let sampleCampaign = "sdk-xmas"

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        Qualifio.shared.setSecureTokenProvider(generateSecureToken)
        Qualifio.shared.setSafariViewControllerCustomizer(customizeSafariViewController)

        let preferences = Preferences.standard

        if let domain = preferences.domain {
            Qualifio.shared.configure(QualifioConfiguration(domain: domain))
        }

        if preferences.configurationFinished && preferences.showCampaignAtLaunch {
            Task {
                do {
                    try await Task.sleep(nanoseconds: 2_000_000_000)
                    try await Qualifio.shared.launchCampaign(Self.sampleCampaign)
                } catch {
                    Logger.main.error("Failed to launch campaign: \(error.localizedDescription)")
                }
            }
        }

        return true
    }

    private func generateSecureToken(_ campaign: String) async throws -> String? {
        let preferences = Preferences.standard

        guard preferences.useSecureToken else {
            return nil
        }

        return try SecureTokenGenerator.generate(
            secret: preferences.secureTokenSecret,
            subject: preferences.secureTokenSubject,
            fields: preferences.secureTokenFields
        )
    }

    private func customizeSafariViewController(_ viewController: SFSafariViewController) {
        viewController.modalPresentationStyle = .fullScreen
    }
}
