import Foundation
import UIKit

@MainActor
public final class QualifioAutoConfig: NSObject {
    @objc public static func setup() {
        addApplicationLaunchListener()
    }

    private static func addApplicationLaunchListener() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didFinishLaunching),
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )
    }

    private static func removeApplicationLaunchListener() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )
    }

    @objc private static func didFinishLaunching() {
        removeApplicationLaunchListener()
        autoConfigure()
    }

    private static func autoConfigure() {
        guard shouldAutoConfigure() else {
            logger.debug("Skipping automatic configuration...")
            return
        }

        Qualifio.shared.configure()
    }

    private static func shouldAutoConfigure() -> Bool {
        guard !Qualifio.shared.isConfigured else {
            logger.debug("Qualifio has already been configured.")
            return false
        }

        if let options = loadOptions(), options.autoConfigEnabled == false {
            logger.debug("Qualifio auto config is disabled.")
            return false
        }

        return true
    }

    private static func loadOptions() -> QualifioOptions? {
        guard let url = Bundle.main.url(forResource: "QualifioOptions", withExtension: "plist") else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            return try decoder.decode(QualifioOptions.self, from: data)
        } catch {
            logger.warning("Could not parse the QualifioOptions.plist file. Please check the contents are valid.")
            return nil
        }
    }
}
