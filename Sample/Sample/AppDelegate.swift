import UIKit
import QualifioKit
import SafariServices

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        Qualifio.shared.configure()

        Qualifio.shared.setSecureTokenProvider(generateSecureToken)
        Qualifio.shared.setSafariViewControllerCustomizer(customizeSafariViewController)

        return true
    }

    private func generateSecureToken(_ campaign: String) async throws -> String? {
        return nil
    }

    private func customizeSafariViewController(_ viewController: SFSafariViewController) {
        viewController.modalPresentationStyle = .fullScreen
    }
}
