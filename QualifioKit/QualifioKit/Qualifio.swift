import UIKit
import SafariServices

@MainActor
public final class Qualifio {
    public static let shared = Qualifio()

    private init() {}

    public private(set) var configuration: QualifioConfiguration?
    public private(set) var options: QualifioOptions?

    public weak var delegate: QualifioDelegate?

    public var isConfigured: Bool {
        configuration != nil
    }

    public func configure(_ configuration: QualifioConfiguration? = nil, options: QualifioOptions? = nil) {
        let configuration = configuration ?? loadConfigurationFile()
        let options = options ?? loadOptionsFile()

        if configuration.domain.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fatalError("Qualifio cannot be configured without a domain.")
        }

        if !configuration.isValid {
            fatalError("Qualifio cannot be configured without a valid set of configurations.")
        }

        logger.hasDebugLoggingEnabled = options.debugLoggingEnabled

        self.configuration = configuration
        self.options = options
    }

    public func launchCampaign(_ campaign: String = "sdk") async throws {
        guard let configuration else {
            throw QualifioError.notConfigured(message: "No configuration set. Please call Qualifio.configure()")
        }

        if campaign.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw QualifioError.invalidArgument(message: "Invalid campaign parameter.")
        }

        guard var url = determineCampaignUrl(campaign.trimmingCharacters(in: .whitespacesAndNewlines), for: configuration) else {
            throw QualifioError.invalidArgument(message: "Unable to construct the campaign URL.")
        }

        logger.debug("Preparing campaign: \(url.absoluteString)")

        do {
            if let token = try await delegate?.qualifio(self, generateSecureTokenFor: url) {
                logger.debug("Setting the provided secure token.")
                url.appendQueryComponent(name: "qual_token", value: token)
            }
        } catch {
            logger.error("Failed to acquire a secure token.", error: error)
        }

        guard let topViewController = UIApplication.shared.topMostViewController() else {
            throw QualifioError.viewControllerNotFound(message: "Unable to find the top most view controller.")
        }

        let campaignViewController = createCampaignViewController(url: url)
        topViewController.present(campaignViewController, animated: true)
    }

    private func loadConfigurationFile() -> QualifioConfiguration {
        guard let url = Bundle.main.url(forResource: "QualifioServices", withExtension: "plist") else {
            fatalError("QualifioServices.plist not found.")
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            return try decoder.decode(QualifioConfiguration.self, from: data)
        } catch {
            fatalError("Could not parse the QualifioServices.plist file. Please check the contents are valid.")
        }
    }

    private func loadOptionsFile() -> QualifioOptions {
        guard let url = Bundle.main.url(forResource: "QualifioOptions", withExtension: "plist") else {
            return QualifioOptions()
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            return try decoder.decode(QualifioOptions.self, from: data)
        } catch {
            logger.warning("Could not parse the QualifioOptions.plist file. Please check the contents are valid.")
            return QualifioOptions()
        }
    }

    private func determineCampaignUrl(_ campaign: String, for configuration: QualifioConfiguration) -> URL? {
        guard var url = URL(string: configuration.host) else {
            return nil
        }

        let campaignPathComponents = campaign.split(separator: "/")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        for component in campaignPathComponents {
            url.appendPathComponent(String(component))
        }

        return url
    }

    private func createCampaignViewController(url: URL) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.modalPresentationStyle = .pageSheet

        delegate?.qualifio(self, customizeSafariViewController: safariViewController)

        return safariViewController
    }
}
