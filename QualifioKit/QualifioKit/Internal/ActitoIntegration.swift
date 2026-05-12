import Foundation
import ObjectiveC

@MainActor
public final class ActitoIntegration: NSObject {

    @objc
    public func launchCampaign(
        _ campaign: String,
        completion: @escaping (Error?) -> Void
    ) {
        Task {
            do {
                try await Qualifio.shared.launchCampaign()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
