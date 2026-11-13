import UIKit
import QualifioKit
import SafariServices

internal class AppDelegate: NSObject, UIApplicationDelegate {
    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

        Qualifio.shared.setSecureTokenProvider(generateSecureToken)
        Qualifio.shared.setSafariViewControllerCustomizer(customizeSafariViewController)

        if Preferences.standard.showCampaignAtLaunch {
            Task {
                do {
                    try await Qualifio.shared.launchCampaign()
                } catch {
                    print("Failed to launch campaign: ", error)
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
