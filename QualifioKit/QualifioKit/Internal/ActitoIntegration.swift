import Foundation
import ObjectiveC

@MainActor
public final class ActitoIntegration: NSObject {
   @objc public func launchCampaign(campaign: String) {
       Qualifio.shared.launchCampaign(campaign)
   }
}
