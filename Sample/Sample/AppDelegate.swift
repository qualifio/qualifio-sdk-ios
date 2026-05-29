import UIKit
import QualifioKit
import SafariServices

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        Qualifio.shared.configure()

        Qualifio.shared.setSecureTokenProvider(generateSecureToken)
        Qualifio.shared.setSafariViewControllerCustomizer(customizeSafariViewController)

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)

            do {
                try await Qualifio.shared.launchCampaign()
            } catch {
                print("Failed to launch campaign: ", error)
            }
        }

        return true
    }

    private func generateSecureToken(_ url: URL) async throws -> String? {
        return nil
    }

    private func customizeSafariViewController(_ viewController: SFSafariViewController) {
        viewController.modalPresentationStyle = .fullScreen
    }
}
