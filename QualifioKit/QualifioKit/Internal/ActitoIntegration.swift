import Foundation
import ObjectiveC

@MainActor
public final class ActitoIntegration: NSObject {
    @objc(launchCampaign:completion:)
    public func launchCampaign(
        _ campaign: String,
        completion: @escaping (NSError?) -> Void
    ) {
        Task {
            do {
                try await Qualifio.shared.launchCampaign(campaign)
                completion(nil)
            } catch {
                completion(error as NSError)
            }
        }
    }
}
