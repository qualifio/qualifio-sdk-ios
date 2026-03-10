import UIKit
import QualifioKit
import SafariServices

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
//        Qualifio.shared.configure()
        Qualifio.shared.delegate = self

        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            Qualifio.shared.launchCampaign()
        }

        return true
    }
}

extension AppDelegate: QualifioDelegate {
    func qualifio(_ qualifio: Qualifio, generateSecureTokenFor url: URL) async throws -> String? {
//        // get from the backend
//        if #available(iOS 16.0, *) {
//            try? await Task.sleep(for: .milliseconds(1500))
//        }

        return nil
    }

    func qualifio(_ qualifio: Qualifio, customizeSafariViewController viewController: SFSafariViewController) {
        viewController.modalPresentationStyle = .fullScreen
    }
}
